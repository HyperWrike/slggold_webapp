import { internalMutation } from "../_generated/server";
import { v } from "convex/values";

export const create = internalMutation({
  args: {
    userId: v.id("profiles"),
    token: v.string(),
    expiresAt: v.number(),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("sessions", args);
  },
});

export const removeByToken = internalMutation({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    const row = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .unique();
    if (row) await ctx.db.delete(row._id);
  },
});

export const removeAllForUser = internalMutation({
  args: { userId: v.id("profiles") },
  handler: async (ctx, { userId }) => {
    const rows = await ctx.db
      .query("sessions")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
    for (const r of rows) await ctx.db.delete(r._id);
  },
});
