import { internalQuery } from "../_generated/server";
import { v } from "convex/values";

export const sessionByToken = internalQuery({
  args: { token: v.string() },
  handler: async (ctx, { token }) => {
    return await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", token))
      .unique();
  },
});
