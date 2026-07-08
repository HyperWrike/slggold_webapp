import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  profiles: defineTable({
    email: v.optional(v.string()),
    passwordHash: v.optional(v.string()),
    full_name: v.string(),
    username: v.optional(v.string()),
    phone: v.optional(v.string()),
    aadhaar: v.optional(v.string()),
    dob: v.optional(v.string()),
    gender: v.optional(v.string()),
    father_name: v.optional(v.string()),
    birth_place: v.optional(v.string()),
    address: v.optional(v.string()),
    nominee_name: v.optional(v.string()),
    nominee_relationship: v.optional(v.string()),
    pin_hash: v.optional(v.string()),
    pin_length: v.optional(v.string()),
    role: v.union(
      v.literal("customer"),
      v.literal("admin"),
      v.literal("manager"),
    ),
    is_verified: v.optional(v.boolean()),
    fcm_token: v.optional(v.string()),
    created_at: v.string(),
    updated_at: v.optional(v.string()),
  })
    .index("by_email", ["email"])
    .index("by_role", ["role"]),

  sessions: defineTable({
    userId: v.id("profiles"),
    token: v.string(),
    expiresAt: v.number(),
  })
    .index("by_token", ["token"])
    .index("by_user", ["userId"])
    .index("by_expiresAt", ["expiresAt"]),

  schemes: defineTable({
    name: v.string(),
    description: v.optional(v.string()),
    metal_type: v.union(
      v.literal("gold"),
      v.literal("silver"),
      v.literal("combo"),
    ),
    monthly_amount: v.number(),
    min_amount: v.optional(v.number()),
    tenure_months: v.number(),
    benefit: v.optional(v.string()),
    gold_benefit_percent: v.optional(v.number()),
    image_url: v.optional(v.string()),
    is_active: v.optional(v.boolean()),
    is_popular: v.optional(v.boolean()),
    created_at: v.string(),
  }).index("by_active", ["is_active"]),

  enrollments: defineTable({
    user_id: v.id("profiles"),
    scheme_id: v.id("schemes"),
    monthly_amount: v.number(),
    tenure_months: v.number(),
    paid_months: v.optional(v.number()),
    total_gold_grams: v.optional(v.number()),
    total_silver_grams: v.optional(v.number()),
    paid_amount: v.optional(v.number()),
    status: v.union(
      v.literal("active"),
      v.literal("completed"),
      v.literal("cancelled"),
      v.literal("paused"),
    ),
    created_at: v.string(),
    updated_at: v.optional(v.string()),
  })
    .index("by_user", ["user_id"])
    .index("by_scheme", ["scheme_id"])
    .index("by_scheme_status", ["scheme_id", "status"]),

  transactions: defineTable({
    user_id: v.optional(v.id("profiles")),
    enrollment_id: v.optional(v.id("enrollments")),
    type: v.union(v.literal("credit"), v.literal("debit")),
    amount: v.number(),
    net_amount: v.optional(v.number()),
    gst: v.optional(v.number()),
    gold_grams: v.optional(v.number()),
    silver_grams: v.optional(v.number()),
    description: v.optional(v.string()),
    razorpay_order_id: v.optional(v.string()),
    razorpay_payment_id: v.optional(v.string()),
    razorpay_signature: v.optional(v.string()),
    status: v.optional(
      v.union(
        v.literal("completed"),
        v.literal("pending"),
        v.literal("failed"),
        v.literal("refunded"),
      ),
    ),
    created_at: v.string(),
  })
    .index("by_user", ["user_id"])
    .index("by_enrollment", ["enrollment_id"])
    .index("by_created", ["created_at"])
    .index("by_order_id", ["razorpay_order_id"]),

  metal_prices: defineTable({
    gold_price: v.number(),
    silver_price: v.number(),
    created_at: v.string(),
  }),

  notifications: defineTable({
    user_id: v.optional(v.id("profiles")),
    title: v.string(),
    message: v.string(),
    icon: v.optional(v.string()),
    type: v.optional(
      v.union(
        v.literal("info"),
        v.literal("payment"),
        v.literal("alert"),
        v.literal("promo"),
        v.literal("system"),
      ),
    ),
    is_read: v.optional(v.boolean()),
    is_global: v.optional(v.boolean()),
    created_at: v.string(),
  })
    .index("by_user", ["user_id"])
    .index("by_global", ["is_global"]),

  gst_rates: defineTable({
    gold_gst: v.number(),
    silver_gst: v.number(),
    making_charges_gst: v.number(),
    created_at: v.string(),
  }),

  rate_limits: defineTable({
    email: v.string(),
    action: v.string(),
    count: v.number(),
    window_start: v.number(),
  })
    .index("by_email_action", ["email", "action"]),
});
