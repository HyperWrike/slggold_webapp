import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin } from "./lib/authHelpers";

export const latest = query({
  args: { sessionToken: v.optional(v.string()) },
  handler: async (ctx) => {
    const rows = await ctx.db.query("gst_rates").collect();
    if (rows.length === 0) return null;
    rows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    return docWithId(rows[0] as Record<string, unknown> & { _id: unknown });
  },
});

export const save = mutation({
  args: {
    sessionToken: v.string(),
    gold_gst: v.number(),
    silver_gst: v.number(),
    making_charges_gst: v.number(),
  },
  handler: async (ctx, args) => {
    await requireAdmin(ctx, args.sessionToken);
    await ctx.db.insert("gst_rates", {
      gold_gst: args.gold_gst,
      silver_gst: args.silver_gst,
      making_charges_gst: args.making_charges_gst,
      created_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});
