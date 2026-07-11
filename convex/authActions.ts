"use node";

import { action } from "./_generated/server";
import { v } from "convex/values";
import { internal } from "./_generated/api";
import type { Id } from "./_generated/dataModel";
import bcrypt from "bcryptjs";
import { randomBytes } from "crypto";
import { docWithId } from "./lib/serialize";
import { encryptAadhaar } from "./lib/crypto";

const RATE_LIMIT_WINDOW = 15 * 60 * 1000;
const RATE_LIMIT_MAX = 5;

async function checkRateLimit(
  ctx: any,
  email: string,
  actionName: string,
): Promise<void> {
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;

  const existing = await ctx.runQuery(
    internal.internal.authHelpers.getRateLimit,
    { email, action: actionName },
  );

  if (existing && existing.window_start >= windowStart) {
    if (existing.count >= RATE_LIMIT_MAX) {
      throw new Error(
        "Too many attempts. Please try again after 15 minutes.",
      );
    }
    await ctx.runMutation(internal.internal.authHelpers.incrementRateLimit, {
      email,
      action: actionName,
    });
  } else {
    await ctx.runMutation(internal.internal.authHelpers.setRateLimit, {
      email,
      action: actionName,
      count: 1,
      window_start: now,
    });
  }
}

function publicProfile(
  doc:
    | ({
        _id: unknown;
        passwordHash?: string;
      } & Record<string, unknown>)
    | null
    | undefined,
) {
  if (!doc) return null;
  const { passwordHash: _p, ...rest } = doc;
  return docWithId(rest as Record<string, unknown> & { _id: unknown });
}

// ============================================================================
// Public API
// ============================================================================

export const register = action({
  args: {
    email: v.string(),
    password: v.string(),
    full_name: v.string(),
    username: v.optional(v.string()),
    phone: v.optional(v.string()),
    aadhaar: v.optional(v.string()),
    dob: v.optional(v.string()),
    gender: v.optional(v.string()),
    father_name: v.optional(v.string()),
    birth_place: v.optional(v.string()),
    address: v.optional(v.string()),
    nominee_name: v.optional(v.string()),
    nominee_relationship: v.optional(v.string()),
    pin_hash: v.optional(v.string()),
    pin_length: v.optional(v.string()),
  },
  handler: async (ctx, args): Promise<{ token: string; profile: unknown }> => {
    await checkRateLimit(ctx, args.email, "register");

    const existing = await ctx.runQuery(
      internal.internal.authHelpers.profileByEmail,
      { email: args.email },
    );
    if (existing) {
      throw new Error("An account with this email already exists.");
    }

    const passwordHash = await bcrypt.hash(args.password, 10);
    const now = new Date().toISOString();

    let encryptedAadhaar: string | undefined;
    if (args.aadhaar) {
      encryptedAadhaar = encryptAadhaar(args.aadhaar);
    }

    const userId: Id<"profiles"> = await ctx.runMutation(
      internal.internal.authHelpers.insertProfile,
      {
        email: args.email,
        passwordHash,
        full_name: args.full_name,
        username: args.username,
        phone: args.phone,
        aadhaar: encryptedAadhaar,
        dob: args.dob,
        gender: args.gender,
        father_name: args.father_name,
        birth_place: args.birth_place,
        address: args.address,
        nominee_name: args.nominee_name,
        nominee_relationship: args.nominee_relationship,
        pin_hash: args.pin_hash,
        pin_length: args.pin_length,
        role: "customer",
        created_at: now,
        is_verified: true,
      },
    );

    const token = randomBytes(32).toString("hex");
    const expiresAt = Date.now() + 30 * 24 * 60 * 60 * 1000;
    await ctx.runMutation(internal.internal.authHelpers.createSession, {
      userId,
      token,
      expiresAt,
    });

    const profile = await ctx.runQuery(
      internal.internal.authHelpers.profileById,
      { id: userId },
    );
    return { token, profile: publicProfile(profile!) };
  },
});

export const login = action({
  args: {
    email: v.string(),
    password: v.string(),
  },
  handler: async (
    ctx,
    { email, password },
  ): Promise<{ token: string; profile: unknown }> => {
    await checkRateLimit(ctx, email, "login");

    const profile: {
      _id: Id<"profiles">;
      passwordHash?: string;
    } | null = await ctx.runQuery(
      internal.internal.authHelpers.profileByEmail,
      { email },
    );
    if (!profile?.passwordHash) {
      throw new Error("Invalid email or password.");
    }
    const ok = await bcrypt.compare(password, profile.passwordHash);
    if (!ok) {
      throw new Error("Invalid email or password.");
    }

    const token = randomBytes(32).toString("hex");
    const expiresAt = Date.now() + 30 * 24 * 60 * 60 * 1000;
    await ctx.runMutation(internal.internal.authHelpers.createSession, {
      userId: profile._id,
      token,
      expiresAt,
    });

    const fresh = await ctx.runQuery(
      internal.internal.authHelpers.profileById,
      { id: profile._id },
    );
    if (fresh && fresh.role === "customer" && fresh.is_verified !== true) {
      throw new Error("Your email address is not verified. Please complete email verification.");
    }
    return { token, profile: publicProfile(fresh!) };
  },
});

export const registerAdmin = action({
  args: {
    email: v.string(),
    password: v.string(),
    full_name: v.optional(v.string()),
    username: v.optional(v.string()),
  },
  handler: async (ctx, args): Promise<{ token: string; profile: unknown }> => {
    const existing = await ctx.runQuery(
      internal.internal.authHelpers.profileByEmail,
      { email: args.email },
    );
    if (existing) {
      throw new Error("An account with this email already exists.");
    }

    const passwordHash = await bcrypt.hash(args.password, 10);
    const now = new Date().toISOString();
    const emailLocal = args.email.split("@")[0] ?? "admin";

    const userId: Id<"profiles"> = await ctx.runMutation(
      internal.internal.authHelpers.insertProfile,
      {
        email: args.email,
        passwordHash,
        full_name: args.full_name ?? "SLG Admin",
        username: args.username ?? emailLocal,
        role: "admin",
        created_at: now,
      },
    );

    const token = randomBytes(32).toString("hex");
    const expiresAt = Date.now() + 30 * 24 * 60 * 60 * 1000;
    await ctx.runMutation(internal.internal.authHelpers.createSession, {
      userId,
      token,
      expiresAt,
    });

    const profile = await ctx.runQuery(
      internal.internal.authHelpers.profileById,
      { id: userId },
    );
    return { token, profile: publicProfile(profile!) };
  },
});

export const changePassword = action({
  args: {
    sessionToken: v.string(),
    currentPassword: v.string(),
    newPassword: v.string(),
  },
  handler: async (ctx, args): Promise<{ ok: boolean }> => {
    const row: {
      _id: Id<"sessions">;
      userId: Id<"profiles">;
      token: string;
      expiresAt: number;
    } | null = await ctx.runQuery(
      internal.internal.authHelpers.sessionByToken,
      { token: args.sessionToken },
    );
    if (!row || row.expiresAt < Date.now()) {
      throw new Error("Unauthorized");
    }

    const profile: {
      _id: Id<"profiles">;
      passwordHash?: string;
    } | null = await ctx.runQuery(
      internal.internal.authHelpers.profileById,
      { id: row.userId },
    );
    if (!profile?.passwordHash) {
      throw new Error("Cannot change password for this account.");
    }

    const ok = await bcrypt.compare(
      args.currentPassword,
      profile.passwordHash,
    );
    if (!ok) {
      throw new Error("Current password is incorrect.");
    }

    const passwordHash = await bcrypt.hash(args.newPassword, 10);
    await ctx.runMutation(internal.internal.authHelpers.updatePasswordHash, {
      userId: profile._id,
      passwordHash,
    });

    return { ok: true };
  },
});
