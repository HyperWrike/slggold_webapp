import { internalQuery } from "../_generated/server";
import { v } from "convex/values";

export const profileByEmail = internalQuery({
  args: { email: v.string() },
  handler: async (ctx, { email }) => {
    return await ctx.db
      .query("profiles")
      .withIndex("by_email", (q) => q.eq("email", email))
      .unique();
  },
});

export const profileById = internalQuery({
  args: { id: v.id("profiles") },
  handler: async (ctx, { id }) => {
    return await ctx.db.get(id);
  },
});
