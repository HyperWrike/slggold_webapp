import type { QueryCtx, MutationCtx } from "../_generated/server";
import type { Id } from "../_generated/dataModel";

export async function getSessionUserId(
  ctx: QueryCtx | MutationCtx,
  sessionToken: string | undefined,
): Promise<Id<"profiles"> | null> {
  if (!sessionToken) return null;
  const row = await ctx.db
    .query("sessions")
    .withIndex("by_token", (q) => q.eq("token", sessionToken))
    .unique();
  if (!row || row.expiresAt < Date.now()) return null;
  return row.userId;
}

export async function requireUser(
  ctx: QueryCtx | MutationCtx,
  sessionToken: string | undefined,
): Promise<Id<"profiles">> {
  const uid = await getSessionUserId(ctx, sessionToken);
  if (!uid) throw new Error("Unauthorized");
  return uid;
}

export async function requireAdmin(
  ctx: QueryCtx | MutationCtx,
  sessionToken: string | undefined,
): Promise<Id<"profiles">> {
  const uid = await requireUser(ctx, sessionToken);
  const profile = await ctx.db.get(uid);
  if (
    !profile ||
    (profile.role !== "admin" && profile.role !== "manager")
  ) {
    throw new Error("Forbidden");
  }
  return uid;
}
