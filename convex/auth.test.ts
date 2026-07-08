import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

process.env.AADHAAR_ENCRYPTION_KEY = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";

describe("authActions", () => {
  test("register and login flow with verification", async () => {
    const t = convexTest(schema);
    
    // 1. Try to login with non-existent user - should throw
    await expect(
      t.action(api.authActions.login, {
        email: "test@example.com",
        password: "password123",
      })
    ).rejects.toThrow();

    // 2. Register a customer user
    const regResult = await t.action(api.authActions.register, {
      email: "test@example.com",
      password: "password123",
      full_name: "Test User",
      username: "test_user",
      phone: "1234567890",
      aadhaar: "123412341234",
      dob: "1990-01-01",
      gender: "male",
      father_name: "Father User",
      birth_place: "Birth City",
      address: "123 Main St",
      nominee_name: "Nominee User",
      nominee_relationship: "brother",
      pin_hash: "1234",
      pin_length: "4",
    });

    expect(regResult.token).toBeDefined();
    expect(regResult.profile.email).toBe("test@example.com");
    expect(regResult.profile.is_verified).toBe(true);

    // 3. Login with correct credentials - should succeed since registration sets is_verified=true
    const loginResult = await t.action(api.authActions.login, {
      email: "test@example.com",
      password: "password123",
    });
    expect(loginResult.token).toBeDefined();
    expect(loginResult.profile.email).toBe("test@example.com");

    // 4. Manually update profile to is_verified=false to test the guard
    const profile = await t.run(async (ctx) => {
      return await ctx.db
        .query("profiles")
        .withIndex("by_email", (q) => q.eq("email", "test@example.com"))
        .first();
    });
    
    await t.run(async (ctx) => {
      await ctx.db.patch(profile!._id, { is_verified: false });
    });

    // 5. Try to login again - should now throw because is_verified is false
    await expect(
      t.action(api.authActions.login, {
        email: "test@example.com",
        password: "password123",
      })
    ).rejects.toThrow("Your email address is not verified.");
  });
});
