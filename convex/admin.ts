import { query } from "./_generated/server";
import { v } from "convex/values";
import { requireAdmin } from "./lib/authHelpers";

export const stats = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    await requireAdmin(ctx, sessionToken);

    const profiles = await ctx.db.query("profiles").collect();
    const customerCount = profiles.filter((p) => p.role === "customer").length;

    const schemes = await ctx.db
      .query("schemes")
      .withIndex("by_active", (q) => q.eq("is_active", true))
      .collect();

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayStart = today.toISOString();

    const txns = await ctx.db.query("transactions").collect();
    let todayCollection = 0;
    let todayTxnCount = 0;
    for (const t of txns) {
      if (t.type !== "credit") continue;
      if (t.created_at >= todayStart) {
        todayCollection += t.amount;
        todayTxnCount++;
      }
    }

    const enrollments = await ctx.db.query("enrollments").collect();
    let totalAUM = 0;
    for (const e of enrollments) {
      totalAUM += e.paid_amount ?? 0;
    }

    return {
      totalCustomers: customerCount,
      activeSchemes: schemes.length,
      todayCollection,
      totalAUM,
      todayTxnCount,
    };
  },
});

export const listCustomers = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    await requireAdmin(ctx, sessionToken);
    const profiles = await ctx.db.query("profiles").collect();
    profiles.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    const customers = profiles.filter((p) => p.role === "customer");
    return customers.map((p) => {
      const { passwordHash: _, ...rest } = p;
      return {
        ...rest,
        id: String(p._id),
      };
    });
  },
});
