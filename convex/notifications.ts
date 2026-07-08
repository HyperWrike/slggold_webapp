import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { requireUser, requireAdmin } from "./lib/authHelpers";
import { docsWithId } from "./lib/serialize";
import type { Id } from "./_generated/dataModel";

export const listUnread = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    const rows = await ctx.db
      .query("notifications")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();
    rows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    const unread = rows.filter(
      (n) => n.is_read !== true && n.user_id === userId,
    );
    return docsWithId(
      unread.map((n) => ({ ...n, _id: n._id })),
    );
  },
});

export const listForUser = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    
    // 1. Fetch user-specific notifications
    const userNotifs = await ctx.db
      .query("notifications")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();
      
    // 2. Fetch global notifications
    const globalNotifs = await ctx.db
      .query("notifications")
      .withIndex("by_global", (q) => q.eq("is_global", true))
      .collect();
      
    // Merge, sort, and slice to prevent unbounded document reading
    const all = [...userNotifs, ...globalNotifs];
    all.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    
    const bounded = all.slice(0, 100);
    return docsWithId(
      bounded.map((n) => ({ ...n, _id: n._id })),
    );
  },
});

export const markRead = mutation({
  args: {
    sessionToken: v.string(),
    notificationId: v.id("notifications"),
  },
  handler: async (ctx, { sessionToken, notificationId }) => {
    const userId = await requireUser(ctx, sessionToken);
    const notif = await ctx.db.get(notificationId);
    if (!notif || notif.user_id !== userId) {
      throw new Error("Notification not found");
    }
    await ctx.db.patch(notificationId, { is_read: true });
    return { ok: true };
  },
});

export const markAllRead = mutation({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    const unread = await ctx.db
      .query("notifications")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();
    for (const n of unread) {
      if (n.is_read !== true) {
        await ctx.db.patch(n._id, { is_read: true });
      }
    }
    return { ok: true };
  },
});

export const create = mutation({
  args: {
    sessionToken: v.string(),
    userId: v.optional(v.string()),
    title: v.string(),
    message: v.string(),
    icon: v.optional(v.string()),
    notifType: v.optional(v.string()),
    isGlobal: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    await requireAdmin(ctx, args.sessionToken);
    
    let targetUserId: Id<"profiles"> | undefined;
    if (args.userId) {
      targetUserId = args.userId as Id<"profiles">;
    }
    
    const notifType = args.notifType as "info" | "payment" | "alert" | "promo" | "system" | undefined;
    
    await ctx.db.insert("notifications", {
      user_id: targetUserId,
      title: args.title,
      message: args.message,
      icon: args.icon ?? "notifications",
      type: notifType ?? "info",
      is_global: args.isGlobal ?? false,
      is_read: false,
      created_at: new Date().toISOString(),
    });
    
    return { ok: true };
  },
});
