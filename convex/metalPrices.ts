import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin } from "./lib/authHelpers";

/** Latest row for caching gold/silver prices (open read; insert matches prior anon usage). */
export const latest = query({
  args: {},
  handler: async (ctx) => {
    const rows = await ctx.db.query("metal_prices").collect();
    if (rows.length === 0) return null;
    rows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    const row = rows[0];
    return {
      id: String(row._id),
      created_at: row.created_at,
      gold_price: row.gold_price,
      silver_price: row.silver_price,
      goldPricePerGram: row.gold_price,
      silverPricePerGram: row.silver_price,
    };
  },
});

export const insert = mutation({
  args: {
    sessionToken: v.string(),
    gold_price: v.number(),
    silver_price: v.number(),
  },
  handler: async (ctx, args) => {
    await requireAdmin(ctx, args.sessionToken);
    await ctx.db.insert("metal_prices", {
      gold_price: args.gold_price,
      silver_price: args.silver_price,
      created_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});
