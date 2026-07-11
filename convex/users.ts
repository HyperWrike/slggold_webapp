import { mutation } from "./_generated/server";
import { v } from "convex/values";
import { requireUser } from "./lib/authHelpers";

export const updatePhone = mutation({
  args: {
    sessionToken: v.string(),
    phone: v.string(),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx, args.sessionToken);
    await ctx.db.patch(userId, {
      phone: args.phone,
      updated_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});

export const changePin = mutation({
  args: {
    sessionToken: v.string(),
    pinHash: v.string(),
    pinLength: v.string(),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx, args.sessionToken);
    await ctx.db.patch(userId, {
      pin_hash: args.pinHash,
      pin_length: args.pinLength,
      updated_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});
