import { mutation, internalAction } from "./_generated/server";
import { internal } from "./_generated/api";
import bcrypt from "bcryptjs";

export const resetAdmin = internalAction({
  args: {},
  handler: async (ctx) => {
    // Delete existing admin if any
    const oldAdmin = await ctx.runQuery(internal.internal.authHelpers.profileByEmail, { email: "Admin@slggolds.com" });
    if (oldAdmin) {
      await ctx.runMutation(internal.internal.authHelpers.deleteProfile, { id: oldAdmin._id });
    }
    const oldAdmin2 = await ctx.runQuery(internal.internal.authHelpers.profileByEmail, { email: "admin@slggolds.com" });
    if (oldAdmin2) {
      await ctx.runMutation(internal.internal.authHelpers.deleteProfile, { id: oldAdmin2._id });
    }

    const email = "admin@slggolds.com";
    const passwordHash = await bcrypt.hash("Admin@pass", 10);
    const now = new Date().toISOString();

    await ctx.runMutation(internal.internal.authHelpers.insertProfile, {
      email,
      passwordHash,
      full_name: "SLG Admin",
      username: "admin",
      role: "admin",
      pin_hash: "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4",
      pin_length: "4",
      created_at: now,
    });

    return { ok: true, message: "Admin reset: admin@slggolds.com / Admin@pass / PIN: 1234" };
  },
});

export const defaultData = mutation({
  args: {},
  handler: async (ctx) => {
    const schemes = await ctx.db.query("schemes").collect();
    if (schemes.length === 0) {
      const now = new Date().toISOString();
      await ctx.db.insert("schemes", {
        name: "Classic Gold Savings Plan",
        description:
          "Secure your future with systematic purchases. SLG pays the 13th month's equivalent as a loyalty bonus on successful completion.",
        metal_type: "gold",
        monthly_amount: 500,
        min_amount: 100,
        tenure_months: 12,
        benefit: "SLG pays the 13th month",
        gold_benefit_percent: 8.33,
        is_active: true,
        is_popular: true,
        created_at: now,
      });
      await ctx.db.insert("schemes", {
        name: "Silver Sterling SIP",
        description: "Pure 999 Silver accumulation with locked-in prices.",
        metal_type: "silver",
        monthly_amount: 1200,
        min_amount: 500,
        tenure_months: 24,
        benefit: "Bonus 2g silver on completion",
        is_active: true,
        is_popular: false,
        created_at: now,
      });
      await ctx.db.insert("schemes", {
        name: "Gold Plus Premium",
        description:
          "Premium gold accumulation with higher monthly commitment and exclusive benefits.",
        metal_type: "gold",
        monthly_amount: 2000,
        min_amount: 1000,
        tenure_months: 24,
        benefit: "10% bonus gold at maturity",
        gold_benefit_percent: 10,
        is_active: true,
        is_popular: false,
        created_at: now,
      });
      await ctx.db.insert("schemes", {
        name: "Festival Gold Combo",
        description: "Gold and Silver combo plan for festive savings.",
        metal_type: "combo",
        monthly_amount: 1500,
        min_amount: 500,
        tenure_months: 18,
        benefit: "Special festival bonus",
        gold_benefit_percent: 5,
        is_active: true,
        is_popular: false,
        created_at: now,
      });
    }

    const notifs = await ctx.db.query("notifications").collect();
    if (notifs.length === 0) {
      const now = new Date().toISOString();
      await ctx.db.insert("notifications", {
        title: "Welcome to SLG Golds",
        message: "Start your gold investment journey today!",
        icon: "star",
        type: "promo",
        is_global: true,
        is_read: false,
        created_at: now,
      });
      await ctx.db.insert("notifications", {
        title: "Gold Price Update",
        message: "Gold prices have increased by 1.2% this week.",
        icon: "trending_up",
        type: "alert",
        is_global: true,
        is_read: false,
        created_at: now,
      });
      await ctx.db.insert("notifications", {
        title: "New Scheme Available",
        message: "Check out our new Silver Sterling SIP plan!",
        icon: "workspace_premium",
        type: "info",
        is_global: true,
        is_read: false,
        created_at: now,
      });
    }

    return { ok: true };
  },
});

export const seedGstProd = mutation({
  args: {},
  handler: async (ctx) => {
    await ctx.db.insert("gst_rates", {
      gold_gst: 3,
      silver_gst: 3,
      making_charges_gst: 18,
      created_at: new Date().toISOString(),
    });
    return { ok: true };
  },
});

