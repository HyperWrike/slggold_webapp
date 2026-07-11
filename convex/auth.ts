import { query, mutation } from "./_generated/server";
import { v } from "convex/values";
import { getSessionUserId } from "./lib/authHelpers";

export const getCurrentUser = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await getSessionUserId(ctx, sessionToken);
    if (!userId) return null;
    const profile = await ctx.db.get(userId);
    if (!profile) return null;
    
    // Return profile with password hash removed, mapping _id to id
    const { passwordHash: _, ...rest } = profile;
    return {
      ...rest,
      id: String(profile._id),
    };
  },
});

export const logout = mutation({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const row = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", sessionToken))
      .unique();
    if (row) {
      await ctx.db.delete(row._id);
      return { ok: true };
    }
    return { ok: false };
  },
});
