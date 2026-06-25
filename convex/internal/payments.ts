import { internalMutation, internalQuery } from "../_generated/server";
import { v } from "convex/values";

export const createPendingTransaction = internalMutation({
  args: {
    userId: v.id("profiles"),
    enrollmentId: v.id("enrollments"),
    amount: v.number(),
    orderId: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("transactions", {
      user_id: args.userId,
      enrollment_id: args.enrollmentId,
      type: "credit",
      amount: args.amount,
      status: "pending",
      razorpay_order_id: args.orderId,
      created_at: new Date().toISOString(),
    });
  },
});

export const getTransactionByOrderId = internalQuery({
  args: { orderId: v.string() },
  handler: async (ctx, { orderId }) => {
    return await ctx.db
      .query("transactions")
      .withIndex("by_order_id", (q) => q.eq("razorpay_order_id", orderId))
      .unique();
  },
});

export const completeTransaction = internalMutation({
  args: {
    transactionId: v.id("transactions"),
    paymentId: v.string(),
    signature: v.string(),
  },
  handler: async (ctx, { transactionId, paymentId, signature }) => {
    const txn = await ctx.db.get(transactionId);
    if (!txn) {
      return { ok: false, error: "Transaction not found" };
    }
    if (txn.status !== "pending") {
      return { ok: false, error: "Transaction is already processed" };
    }

    const enrollmentId = txn.enrollment_id;
    if (!enrollmentId) {
      return { ok: false, error: "No enrollment associated with transaction" };
    }

    const enr = await ctx.db.get(enrollmentId);
    if (!enr) {
      return { ok: false, error: "Enrollment not found" };
    }

    // Retrieve latest gold price per gram
    const priceRows = await ctx.db.query("metal_prices").collect();
    priceRows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    let goldPrice = priceRows[0]?.gold_price ?? 7850;
    if (goldPrice <= 0) goldPrice = 7850;

    // Calculate GST (Standard Gold GST in India is 3%)
    const netAmount = txn.amount / 1.03;
    const gstAmount = txn.amount - netAmount;

    // Calculate Gold Grams
    const goldGrams = netAmount / goldPrice;

    // Update Transaction
    await ctx.db.patch(transactionId, {
      status: "completed",
      net_amount: netAmount,
      gst: gstAmount,
      gold_grams: goldGrams,
      razorpay_payment_id: paymentId,
      razorpay_signature: signature,
    });

    // Update Enrollment
    const newPaidMonths = (enr.paid_months ?? 0) + 1;
    const newPaidAmount = (enr.paid_amount ?? 0) + txn.amount;
    const newTotalGold = (enr.total_gold_grams ?? 0) + goldGrams;

    const isCompleted = newPaidMonths >= enr.tenure_months;

    await ctx.db.patch(enrollmentId, {
      paid_months: newPaidMonths,
      paid_amount: newPaidAmount,
      total_gold_grams: newTotalGold,
      status: isCompleted ? "completed" : enr.status,
      updated_at: new Date().toISOString(),
    });

    return { ok: true };
  },
});

export const getEnrollment = internalQuery({
  args: { id: v.id("enrollments") },
  handler: async (ctx, { id }) => {
    return await ctx.db.get(id);
  },
});
