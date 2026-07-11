import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("payments", () => {
  test("complete payment flow with order creation, pending transaction, and verification", async () => {
    const t = convexTest(schema);

    // Set AADHAAR_ENCRYPTION_KEY just in case, and RAZORPAY key to trigger mock mode or run cleanly
    process.env.AADHAAR_ENCRYPTION_KEY = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

    // 1. Setup database (profile, session, scheme, enrollment, metal prices, GST rates)
    const { customerToken, enrollmentId, schemeId } = await t.run(async (ctx) => {
      const customerId = await ctx.db.insert("profiles", {
        full_name: "Customer User",
        email: "customer@example.com",
        role: "customer",
        created_at: new Date().toISOString(),
        is_verified: true,
      });

      const customerSessionToken = "customer_session_token";
      await ctx.db.insert("sessions", {
        userId: customerId,
        token: customerSessionToken,
        expiresAt: Date.now() + 1000 * 60 * 60,
      });

      const sId = await ctx.db.insert("schemes", {
        name: "Gold Standard",
        metal_type: "gold",
        monthly_amount: 1000,
        tenure_months: 2, // Low tenure for testing completion
        is_active: true,
        created_at: new Date().toISOString(),
      });

      const enrId = await ctx.db.insert("enrollments", {
        user_id: customerId,
        scheme_id: sId,
        monthly_amount: 1000,
        tenure_months: 2,
        paid_months: 0,
        paid_amount: 0,
        total_gold_grams: 0,
        status: "active",
        created_at: new Date().toISOString(),
      });

      // Insert metal prices
      await ctx.db.insert("metal_prices", {
        gold_price: 5000, // ₹5000 per gram
        silver_price: 100,
        created_at: new Date().toISOString(),
      });

      // Insert GST rate
      await ctx.db.insert("gst_rates", {
        gold_gst: 3,
        silver_gst: 3,
        making_charges_gst: 5,
        created_at: new Date().toISOString(),
      });

      return {
        customerToken: customerSessionToken,
        enrollmentId: enrId,
        schemeId: sId,
      };
    });

    // 2. Create Order
    const order = await t.action(api.payments.createOrder, {
      sessionToken: customerToken,
      enrollmentId,
      amount: 1000,
    });
    expect(order.orderId).toBeDefined();
    expect(order.amount).toBe(1000);
    expect(order.isMock).toBe(true); // Should be mock since no credentials set

    // Verify pending transaction exists
    const txns: any = await t.run(async (ctx) => {
      return await ctx.db.query("transactions").collect();
    });
    expect(txns.length).toBe(1);
    expect(txns[0].status).toBe("pending");
    expect(txns[0].amount).toBe(1000);

    // 3. Verify Payment
    const verifyResult = await t.action(api.payments.verifyPayment, {
      sessionToken: customerToken,
      razorpayOrderId: order.orderId,
      razorpayPaymentId: "pay_test123",
      razorpaySignature: "sig_test123",
    });
    expect(verifyResult.ok).toBe(true);

    // 4. Verify Database state after transaction complete
    const completedTxns: any = await t.run(async (ctx) => {
      return await ctx.db.query("transactions").collect();
    });
    expect(completedTxns[0].status).toBe("completed");
    
    // Net amount calculation: 1000 / 1.03 = 970.8737
    // GST: 1000 - 970.8737 = 29.126
    expect(completedTxns[0].net_amount).toBeCloseTo(970.87, 1);
    expect(completedTxns[0].gst).toBeCloseTo(29.13, 1);

    // Gold grams: 970.8737 / 5000 = 0.19417
    expect(completedTxns[0].gold_grams).toBeCloseTo(0.194, 3);

    // Verify Enrollment updated
    const updatedEnrollment: any = await t.run(async (ctx) => {
      return await ctx.db.get(enrollmentId);
    });
    expect(updatedEnrollment.paid_months).toBe(1);
    expect(updatedEnrollment.paid_amount).toBe(1000);
    expect(updatedEnrollment.total_gold_grams).toBeCloseTo(0.194, 3);
    expect(updatedEnrollment.status).toBe("active"); // Since tenure is 2, and paid_months is 1

    // 5. Complete second payment to trigger enrollment completion
    const order2 = await t.action(api.payments.createOrder, {
      sessionToken: customerToken,
      enrollmentId,
      amount: 1000,
    });
    await t.action(api.payments.verifyPayment, {
      sessionToken: customerToken,
      razorpayOrderId: order2.orderId,
      razorpayPaymentId: "pay_test456",
      razorpaySignature: "sig_test456",
    });

    const finalEnrollment: any = await t.run(async (ctx) => {
      return await ctx.db.get(enrollmentId);
    });
    expect(finalEnrollment.paid_months).toBe(2);
    expect(finalEnrollment.paid_amount).toBe(2000);
    expect(finalEnrollment.status).toBe("completed"); // tenure reached!
  });
});
