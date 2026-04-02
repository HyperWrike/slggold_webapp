import { query } from "./_generated/server";
import { v } from "convex/values";
import { requireUser } from "./lib/authHelpers";

export const summary = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);

    const enrollments = await ctx.db
      .query("enrollments")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();

    let totalGold = 0;
    let totalInvested = 0;
    let activeCount = 0;

    const priceRows = await ctx.db.query("metal_prices").collect();
    priceRows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    let goldPrice = priceRows[0]?.gold_price ?? 7850;

    if (goldPrice <= 0) goldPrice = 7850;

    for (const e of enrollments) {
      const grams = e.total_gold_grams ?? 0;
      const invested = e.paid_amount ?? 0;
      const status = e.status ?? "";
      totalGold += grams;
      totalInvested += invested;
      if (status === "active") activeCount++;
    }

    let totalCurrentValue = 0;
    for (const e of enrollments) {
      const grams = e.total_gold_grams ?? 0;
      totalCurrentValue += grams * goldPrice;
    }

    return {
      totalGoldGrams: totalGold,
      totalValue: totalInvested,
      currentValue: totalCurrentValue,
      goldPricePerGram: goldPrice,
      activeEnrollments: activeCount,
      totalEnrollments: enrollments.length,
    };
  },
});
