import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";
import bcrypt from "bcryptjs";

describe("users actions", () => {
  test("profile phone and PIN mutation updates and password action changes", async () => {
    const t = convexTest(schema);

    // 1. Setup mock profiles and sessions
    const { customerToken, customerUserId } = await t.run(async (ctx) => {
      const passwordHash = await bcrypt.hash("old_password123", 10);
      const customerId = await ctx.db.insert("profiles", {
        full_name: "Customer User",
        email: "customer@example.com",
        role: "customer",
        passwordHash,
        phone: "1234567890",
        pin_hash: "pin_old",
        pin_length: "4",
        created_at: new Date().toISOString(),
        is_verified: true,
      });

      const customerSessionToken = "customer_session_token";
      await ctx.db.insert("sessions", {
        userId: customerId,
        token: customerSessionToken,
        expiresAt: Date.now() + 1000 * 60 * 60,
      });

      return {
        customerToken: customerSessionToken,
        customerUserId: customerId,
      };
    });

    // 2. Test updatePhone
    const phoneResult = await t.mutation(api.users.updatePhone, {
      sessionToken: customerToken,
      phone: "0987654321",
    });
    expect(phoneResult.ok).toBe(true);

    const profileAfterPhone: any = await t.run(async (ctx) => {
      return await ctx.db.get(customerUserId);
    });
    expect(profileAfterPhone.phone).toBe("0987654321");

    // 3. Test changePin
    const pinResult = await t.mutation(api.users.changePin, {
      sessionToken: customerToken,
      pinHash: "pin_new_hash",
      pinLength: "6",
    });
    expect(pinResult.ok).toBe(true);

    const profileAfterPin: any = await t.run(async (ctx) => {
      return await ctx.db.get(customerUserId);
    });
    expect(profileAfterPin.pin_hash).toBe("pin_new_hash");
    expect(profileAfterPin.pin_length).toBe("6");

    // 4. Test changePassword with incorrect old password - should throw
    await expect(
      t.action(api.authActions.changePassword, {
        sessionToken: customerToken,
        currentPassword: "wrong_old_password",
        newPassword: "new_password123",
      })
    ).rejects.toThrow("Current password is incorrect.");

    // 5. Test changePassword with correct old password - should succeed
    const passwordResult = await t.action(api.authActions.changePassword, {
      sessionToken: customerToken,
      currentPassword: "old_password123",
      newPassword: "new_password123",
    });
    expect(passwordResult.ok).toBe(true);

    // Verify hash changed and password matches the new one
    const profileAfterPassword: any = await t.run(async (ctx) => {
      return await ctx.db.get(customerUserId);
    });
    const matchesNew = await bcrypt.compare("new_password123", profileAfterPassword.passwordHash);
    expect(matchesNew).toBe(true);
  });
});
