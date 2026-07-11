import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("metalPrices", () => {
  test("metal prices CRUD operations and authentication", async () => {
    const t = convexTest(schema);

    // 1. Setup mock profiles and sessions
    const { adminToken, customerToken } = await t.run(async (ctx) => {
      const adminId = await ctx.db.insert("profiles", {
        full_name: "Admin User",
        email: "admin@example.com",
        role: "admin",
        created_at: new Date().toISOString(),
        is_verified: true,
      });

      const customerId = await ctx.db.insert("profiles", {
        full_name: "Customer User",
        email: "customer@example.com",
        role: "customer",
        created_at: new Date().toISOString(),
        is_verified: true,
      });

      const adminSessionToken = "admin_session_token";
      await ctx.db.insert("sessions", {
        userId: adminId,
        token: adminSessionToken,
        expiresAt: Date.now() + 1000 * 60 * 60,
      });

      const customerSessionToken = "customer_session_token";
      await ctx.db.insert("sessions", {
        userId: customerId,
        token: customerSessionToken,
        expiresAt: Date.now() + 1000 * 60 * 60,
      });

      return {
        adminToken: adminSessionToken,
        customerToken: customerSessionToken,
      };
    });

    // 2. Query latest when empty - should return null
    const emptyPrice = await t.query(api.metalPrices.latest, {});
    expect(emptyPrice).toBeNull();

    // 3. Try to insert prices as customer - should throw Forbidden
    await expect(
      t.mutation(api.metalPrices.insert, {
        sessionToken: customerToken,
        gold_price: 5000,
        silver_price: 100,
      })
    ).rejects.toThrow("Forbidden");

    // 4. Insert prices as admin - should succeed
    const insertResult = await t.mutation(api.metalPrices.insert, {
      sessionToken: adminToken,
      gold_price: 5500,
      silver_price: 110,
    });
    expect(insertResult.ok).toBe(true);

    // 5. Query latest - should return the newly inserted prices
    const latestPrice: any = await t.query(api.metalPrices.latest, {});
    expect(latestPrice).not.toBeNull();
    expect(latestPrice.gold_price).toBe(5500);
    expect(latestPrice.silver_price).toBe(110);
    expect(latestPrice.goldPricePerGram).toBe(5500);
    expect(latestPrice.silverPricePerGram).toBe(110);
  });
});
