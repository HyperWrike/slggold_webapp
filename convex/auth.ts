import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { getSessionUserId } from "./lib/authHelpers";

export const getCurrentUser = query({
  args: { sessionToken: v.optional(v.string()) },
  handler: async (ctx, { sessionToken }) => {
    const uid = await getSessionUserId(ctx, sessionToken);
    if (!uid) return null;
    const doc = await ctx.db.get(uid);
    if (!doc) return null;
    const { passwordHash: _, ...rest } = doc;
    return docWithId(rest as Record<string, unknown> & { _id: unknown });
  },
});

export const logout = mutation({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const row = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", sessionToken))
      .unique();
    if (row) await ctx.db.delete(row._id);
    return { ok: true };
  },
});

export const updatePin = mutation({
  args: {
    sessionToken: v.string(),
    pin_hash: v.string(),
  },
  handler: async (ctx, { sessionToken, pin_hash }) => {
    const uid = await getSessionUserId(ctx, sessionToken);
    if (!uid) throw new Error("Unauthorized");
    await ctx.db.patch(uid, {
      pin_hash,
      updated_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});

export const updatePhone = mutation({
  args: {
    sessionToken: v.string(),
    phone: v.string(),
  },
  handler: async (ctx, { sessionToken, phone }) => {
    const uid = await getSessionUserId(ctx, sessionToken);
    if (!uid) throw new Error("Unauthorized");
    await ctx.db.patch(uid, {
      phone,
      updated_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});
