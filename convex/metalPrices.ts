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
    return docWithId(rows[0] as Record<string, unknown> & { _id: unknown });
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
