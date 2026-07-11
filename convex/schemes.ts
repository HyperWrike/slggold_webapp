import { mutation, query } from "./_generated/server";
import { v } from "convex/values";
import { docWithId } from "./lib/serialize";
import { requireAdmin } from "./lib/authHelpers";

export const listActive = query({
  args: {},
  handler: async (ctx) => {
    const rows = await ctx.db
      .query("schemes")
      .withIndex("by_active", (q) => q.eq("is_active", true))
      .collect();
    rows.sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
    return rows.map((r) => docWithId(r as Record<string, unknown> & { _id: unknown }));
  },
});

export const create = mutation({
  args: {
    sessionToken: v.string(),
    name: v.string(),
    description: v.string(),
    metal_type: v.union(
      v.literal("gold"),
      v.literal("silver"),
      v.literal("combo"),
    ),
    monthly_amount: v.number(),
    min_amount: v.number(),
    tenure_months: v.number(),
    benefit: v.string(),
    is_popular: v.boolean(),
  },
  handler: async (ctx, args) => {
    await requireAdmin(ctx, args.sessionToken);
    const { sessionToken: _, ...rest } = args;
    await ctx.db.insert("schemes", {
      ...rest,
      is_active: true,
      created_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});

export const toggleStatus = mutation({
  args: {
    sessionToken: v.string(),
    schemeId: v.id("schemes"),
    isActive: v.boolean(),
  },
  handler: async (ctx, { sessionToken, schemeId, isActive }) => {
    await requireAdmin(ctx, sessionToken);
    await ctx.db.patch(schemeId, { is_active: isActive });
    return { ok: true };
  },
});

export const remove = mutation({
  args: {
    sessionToken: v.string(),
    schemeId: v.id("schemes"),
  },
  handler: async (ctx, { sessionToken, schemeId }) => {
    await requireAdmin(ctx, sessionToken);

    const enrollments = await ctx.db
      .query("enrollments")
      .withIndex("by_scheme", (q) => q.eq("scheme_id", schemeId))
      .collect();

    const activeCount = enrollments.filter((e) => e.status === "active").length;
    if (activeCount > 0) {
      throw new Error(
        `Cannot delete: scheme has ${activeCount} active enrollment${activeCount > 1 ? "s" : ""}`,
      );
    }

    for (const e of enrollments) {
      await ctx.db.delete(e._id);
    }

    await ctx.db.delete(schemeId);
    return { ok: true };
  },
});

export const get = query({
  args: {
    id: v.id("schemes"),
  },
  handler: async (ctx, args) => {
    const scheme = await ctx.db.get(args.id);
    if (!scheme) return null;
    return docWithId(scheme as Record<string, unknown> & { _id: unknown });
  },
});
