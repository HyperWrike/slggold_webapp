import { internalMutation } from "../_generated/server";
import { v } from "convex/values";

export const insertCustomer = internalMutation({
  args: {
    email: v.string(),
    passwordHash: v.string(),
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
    created_at: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("profiles", {
      email: args.email,
      passwordHash: args.passwordHash,
      full_name: args.full_name,
      username: args.username,
      phone: args.phone,
      aadhaar: args.aadhaar,
      dob: args.dob,
      gender: args.gender,
      father_name: args.father_name,
      birth_place: args.birth_place,
      address: args.address,
      nominee_name: args.nominee_name,
      nominee_relationship: args.nominee_relationship,
      pin_hash: args.pin_hash,
      pin_length: args.pin_length,
      role: args.role,
      is_verified: false,
      created_at: args.created_at,
    });
  },
});

export const updatePasswordHash = internalMutation({
  args: {
    userId: v.id("profiles"),
    passwordHash: v.string(),
  },
  handler: async (ctx, { userId, passwordHash }) => {
    await ctx.db.patch(userId, { passwordHash, updated_at: new Date().toISOString() });
  },
});
