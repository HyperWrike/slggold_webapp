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

    let totalGoldGrams = 0;
    let totalSilverGrams = 0;
    let totalInvested = 0;
    let activeCount = 0;

    const priceRows = await ctx.db.query("metal_prices").collect();
    priceRows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    let goldPrice = priceRows[0]?.gold_price ?? 7850;
    let silverPrice = priceRows[0]?.silver_price ?? 7850;
    if (goldPrice <= 0) goldPrice = 7850;
    if (silverPrice <= 0) silverPrice = 7850;

    for (const e of enrollments) {
      const scheme = e.scheme_id
        ? await ctx.db.get(e.scheme_id)
        : null;
      const metalType = scheme?.metal_type ?? "gold";
      const goldGrams = e.total_gold_grams ?? 0;
      const silverGrams = e.total_silver_grams ?? 0;
      const invested = e.paid_amount ?? 0;
      const status = e.status ?? "";

      if (metalType === "gold" || metalType === "combo") {
        totalGoldGrams += goldGrams;
      }
      if (metalType === "silver" || metalType === "combo") {
        totalSilverGrams += silverGrams;
      }
      totalInvested += invested;
      if (status === "active") activeCount++;
    }

    const currentGoldValue = totalGoldGrams * goldPrice;
    const currentSilverValue = totalSilverGrams * silverPrice;
    const totalCurrentValue = currentGoldValue + currentSilverValue;

    return {
      totalGoldGrams,
      totalSilverGrams,
      totalValue: totalInvested,
      currentValue: totalCurrentValue,
      goldPricePerGram: goldPrice,
      silverPricePerGram: silverPrice,
      activeEnrollments: activeCount,
      totalEnrollments: enrollments.length,
    };
  },
});
