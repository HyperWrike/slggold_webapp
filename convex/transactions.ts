import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin, requireUser } from "./lib/authHelpers";
export const listForUser = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);

    const enrollments = await ctx.db
      .query("enrollments")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();

    if (enrollments.length === 0) {
      const direct = await ctx.db
        .query("transactions")
        .withIndex("by_user", (q) => q.eq("user_id", userId))
        .collect();
      direct.sort(
        (a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
      );
      return direct
        .slice(0, 50)
        .map((r) => docWithId(r as Record<string, unknown> & { _id: unknown }));
    }

    const enrollmentIds = new Set(enrollments.map((e) => e._id));
    const all: import("./_generated/dataModel").Doc<"transactions">[] = [];
    for (const eid of enrollmentIds) {
      const txns = await ctx.db
        .query("transactions")
        .withIndex("by_enrollment", (q) => q.eq("enrollment_id", eid))
        .collect();
      all.push(...txns);
    }
    all.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    return all
      .slice(0, 50)
      .map((r) => docWithId(r as Record<string, unknown> & { _id: unknown }));
  },
});

export const recordPayment = mutation({
  args: {
    sessionToken: v.string(),
    enrollmentId: v.id("enrollments"),
    amount: v.number(),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx, args.sessionToken);
    const enr = await ctx.db.get(args.enrollmentId);
    if (!enr || enr.user_id !== userId) {
      throw new Error("Invalid enrollment");
    }
    await ctx.db.insert("transactions", {
      enrollment_id: args.enrollmentId,
      user_id: userId,
      type: "credit",
      amount: args.amount,
      status: "completed",
      created_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});

export const listAllForAdmin = query({
  args: {
    sessionToken: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, { sessionToken, limit }) => {
    await requireAdmin(ctx, sessionToken);
    const lim = limit ?? 100;
    const txns = await ctx.db.query("transactions").collect();
    txns.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    const slice = txns.slice(0, lim);

    const profiles = await ctx.db.query("profiles").collect();
    const profileMap = new Map(
      profiles.map((p) => [String(p._id), p] as const),
    );

    return slice.map((txn) => {
      const base = docWithId(txn as Record<string, unknown> & { _id: unknown });
      const uid = txn.user_id
        ? (String(txn.user_id) as string)
        : null;
      const p = uid ? profileMap.get(uid) : null;
      return {
        ...base,
        user_name: p?.full_name ?? "",
        user_username: p?.username ?? "",
      };
    });
  },
});
