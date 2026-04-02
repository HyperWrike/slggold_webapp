import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin, requireUser } from "./lib/authHelpers";

export const listForUser = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    const all = await ctx.db.query("notifications").collect();
    const mine = all.filter(
      (n) =>
        (n.user_id && String(n.user_id) === String(userId)) ||
        n.is_global === true,
    );
    mine.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    return mine
      .slice(0, 50)
      .map((r) => docWithId(r as Record<string, unknown> & { _id: unknown }));
  },
});

export const markRead = mutation({
  args: {
    sessionToken: v.string(),
    notificationId: v.id("notifications"),
  },
  handler: async (ctx, { sessionToken, notificationId }) => {
    await requireUser(ctx, sessionToken);
    await ctx.db.patch(notificationId, { is_read: true });
  },
});

export const markAllRead = mutation({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    const all = await ctx.db.query("notifications").collect();
    for (const n of all) {
      if (n.user_id && String(n.user_id) === String(userId) && !n.is_read) {
        await ctx.db.patch(n._id, { is_read: true });
      }
    }
  },
});

export const create = mutation({
  args: {
    sessionToken: v.string(),
    userId: v.optional(v.id("profiles")),
    title: v.string(),
    message: v.string(),
    icon: v.optional(v.string()),
    notifType: v.optional(
      v.union(
        v.literal("info"),
        v.literal("payment"),
        v.literal("alert"),
        v.literal("promo"),
        v.literal("system"),
      ),
    ),
    isGlobal: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    await requireAdmin(ctx, args.sessionToken);
    await ctx.db.insert("notifications", {
      user_id: args.userId,
      title: args.title,
      message: args.message,
      icon: args.icon ?? "notifications",
      type: args.notifType ?? "info",
      is_read: false,
      is_global: args.isGlobal ?? false,
      created_at: new Date().toISOString(),
    });
  },
});
