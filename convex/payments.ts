"use node";

import { action } from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";
import { createHmac, randomBytes, timingSafeEqual } from "crypto";

// Razorpay credentials from environment variables
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;

// Determine if we are in mock mode (no keys or placeholder)
const isMockMode =
  !RAZORPAY_KEY_ID ||
  !RAZORPAY_KEY_SECRET ||
  RAZORPAY_KEY_ID.includes("placeholder");

/**
 * Create a Razorpay order (or a mock order when in mock mode)
 */
export const createOrder = action({
  args: {
    sessionToken: v.string(),
    enrollmentId: v.id("enrollments"),
    amount: v.number(),
  },
  handler: async (ctx, args) => {
    // 1️⃣ Authenticate user via Convex session token
    const session = await ctx.runQuery(internal.internal.authHelpers.sessionByToken, {
      token: args.sessionToken,
    });
    if (!session || session.expiresAt < Date.now()) {
      throw new Error("Unauthorized");
    }
    const userId = session.userId;

    // 2️⃣ Verify enrollment belongs to this user
    const enrollment = await ctx.runQuery(internal.internal.payments.getEnrollment, {
      id: args.enrollmentId,
    });
    if (!enrollment || enrollment.user_id !== userId) {
      throw new Error("Invalid enrollment");
    }

    // 3️⃣ Server-side amount validation
    if (args.amount < 100) {
      throw new Error("Amount below minimum (₹100)");
    }
    if (args.amount > 100000) {
      throw new Error("Amount exceeds maximum (₹1,00,000)");
    }

    // 4️⃣ Create Razorpay order (or mock order)
    let orderId: string;
    if (isMockMode) {
      orderId = "order_mock_" + randomBytes(8).toString("hex");
      console.log(`[Payments] Mock order generated: ${orderId}`);
    } else {
      // Real Razorpay request – Node fetch works in the Node runtime
      const authHeader =
        "Basic " +
        Buffer.from(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`).toString("base64");

      const resp = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: {
          Authorization: authHeader,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          amount: Math.round(args.amount * 100), // paise
          currency: "INR",
          receipt: args.enrollmentId,
        }),
      });
      if (!resp.ok) {
        const txt = await resp.text();
        throw new Error(`Razorpay API error ${resp.status}: ${txt}`);
      }
      const data = await resp.json();
      orderId = data.id;
    }

    // 4️⃣ Record a pending transaction in Convex
    await ctx.runMutation(internal.internal.payments.createPendingTransaction, {
      userId,
      enrollmentId: args.enrollmentId,
      amount: args.amount,
      orderId,
    });

    // 5️⃣ Return data for the front‑end payment handler
    return {
      orderId,
      amount: args.amount,
      currency: "INR",
      key: isMockMode ? "rzp_test_mockkey" : RAZORPAY_KEY_ID!,
      isMock: isMockMode,
    };
  },
});

/**
 * Verify Razorpay signature and mark the transaction as complete.
 */
export const verifyPayment = action({
  args: {
    sessionToken: v.string(),
    razorpayOrderId: v.string(),
    razorpayPaymentId: v.string(),
    razorpaySignature: v.string(),
  },
  handler: async (ctx, args) => {
    // 1️⃣ Authenticate user
    const session = await ctx.runQuery(internal.internal.authHelpers.sessionByToken, {
      token: args.sessionToken,
    });
    if (!session || session.expiresAt < Date.now()) {
      throw new Error("Unauthorized");
    }

    // 2️⃣ Find the pending transaction by order ID
    const txn = await ctx.runQuery(internal.internal.payments.getTransactionByOrderId, {
      orderId: args.razorpayOrderId,
    });
    if (!txn) throw new Error("Transaction not found");
    if (txn.user_id !== session.userId) throw new Error("Transaction belongs to another user");

    // 3️⃣ Verify signature (skip for mock orders)
    let verified = false;
    if (isMockMode || args.razorpayOrderId.startsWith("order_mock_")) {
      verified = true;
      console.log(`[Payments] Mock verification passed for ${args.razorpayOrderId}`);
    } else {
      const hmac = createHmac("sha256", RAZORPAY_KEY_SECRET!);
      hmac.update(`${args.razorpayOrderId}|${args.razorpayPaymentId}`);
      const expected = hmac.digest("hex");
      const expectedBuf = Buffer.from(expected, "hex");
      const actualBuf = Buffer.from(args.razorpaySignature, "hex");
      verified =
        expectedBuf.length === actualBuf.length &&
        timingSafeEqual(expectedBuf, actualBuf);
      if (!verified) {
        console.warn("[Payments] Signature mismatch");
      }
    }
    if (!verified) throw new Error("Payment signature verification failed");

    // 4️⃣ Complete the transaction atomically
    const result = await ctx.runMutation(internal.internal.payments.completeTransaction, {
      transactionId: txn._id,
      paymentId: args.razorpayPaymentId,
      signature: args.razorpaySignature,
    });
    if (!result.ok) throw new Error(result.error ?? "Failed to finalize transaction");

    return { ok: true };
  },
});
