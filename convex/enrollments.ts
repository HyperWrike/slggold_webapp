import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin, requireUser } from "./lib/authHelpers";

export const listForUserWithSchemes = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    const userId = await requireUser(ctx, sessionToken);
    const enrollments = await ctx.db
      .query("enrollments")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();
    enrollments.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );

    const schemes = await ctx.db.query("schemes").collect();
    const schemeMap = new Map(schemes.map((s) => [String(s._id), s]));

    return enrollments.map((e) => {
      const base = docWithId(e as Record<string, unknown> & { _id: unknown });
      const sid = String(e.scheme_id);
      const sch = schemeMap.get(sid);
      return {
        ...base,
        schemes: sch
          ? docWithId(sch as Record<string, unknown> & { _id: unknown })
          : null,
      };
    });
  },
});

export const listAllForReports = query({
  args: { sessionToken: v.string() },
  handler: async (ctx, { sessionToken }) => {
    await requireAdmin(ctx, sessionToken);
    const rows = await ctx.db.query("enrollments").collect();
    return rows.map((r) => docWithId(r as Record<string, unknown> & { _id: unknown }));
  },
});

export const listForCustomerUserId = query({
  args: {
    sessionToken: v.string(),
    customerUserId: v.string(),
  },
  handler: async (ctx, { sessionToken, customerUserId }) => {
    await requireAdmin(ctx, sessionToken);
    const userId = customerUserId as import("./_generated/dataModel").Id<"profiles">;
    const enrollments = await ctx.db
      .query("enrollments")
      .withIndex("by_user", (q) => q.eq("user_id", userId))
      .collect();
    enrollments.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    const schemes = await ctx.db.query("schemes").collect();
    const schemeMap = new Map(schemes.map((s) => [String(s._id), s]));
    return enrollments.map((e) => {
      const base = docWithId(e as Record<string, unknown> & { _id: unknown });
      const sch = schemeMap.get(String(e.scheme_id));
      return {
        ...base,
        schemes: sch
          ? docWithId(sch as Record<string, unknown> & { _id: unknown })
          : null,
      };
    });
  },
});

export const create = mutation({
  args: {
    sessionToken: v.string(),
    schemeId: v.id("schemes"),
    monthlyAmount: v.number(),
    tenureMonths: v.number(),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx, args.sessionToken);
    const id = await ctx.db.insert("enrollments", {
      user_id: userId,
      scheme_id: args.schemeId,
      monthly_amount: args.monthlyAmount,
      tenure_months: args.tenureMonths,
      paid_months: 0,
      total_gold_grams: 0,
      paid_amount: 0,
      status: "active",
      created_at: new Date().toISOString(),
    return { ok: true, id: String(id) };
  },
});

export const countActiveForScheme = query({
  args: {
    sessionToken: v.string(),
    schemeId: v.id("schemes"),
  },
  handler: async (ctx, { sessionToken, schemeId }) => {
    await requireAdmin(ctx, sessionToken);
    const rows = await ctx.db
      .query("enrollments")
      .withIndex("by_scheme", (q) => q.eq("scheme_id", schemeId))
      .collect();
    return rows.filter((r) => r.status === "active").length;
  },
});

export const countActiveForUser = query({
  args: {
    sessionToken: v.string(),
    userId: v.string(),
  },
  handler: async (ctx, { sessionToken, userId }) => {
    await requireAdmin(ctx, sessionToken);
    const uid = userId as import("./_generated/dataModel").Id<"profiles">;
    const rows = await ctx.db
      .query("enrollments")
      .withIndex("by_user", (q) => q.eq("user_id", uid))
      .filter((q) => q.eq(q.field("status"), "active"))
      .collect();
    return rows.length;
  },
});
