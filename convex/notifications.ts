import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { requireUser } from "./lib/authHelpers";
import { docsWithId } from "./lib/serialize";

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
