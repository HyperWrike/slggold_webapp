import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("gst", () => {
  test("gst rates CRUD operations and authorization", async () => {
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
    const emptyGst = await t.query(api.gst.latest, {});
    expect(emptyGst).toBeNull();

    // 3. Try to save gst as customer - should fail with Forbidden
    await expect(
      t.mutation(api.gst.save, {
        sessionToken: customerToken,
        gold_gst: 3,
        silver_gst: 3,
        making_charges_gst: 5,
      })
    ).rejects.toThrow("Forbidden");

    // 4. Save gst as admin - should succeed
    const saveResult = await t.mutation(api.gst.save, {
      sessionToken: adminToken,
      gold_gst: 3,
      silver_gst: 5,
      making_charges_gst: 10,
    });
    expect(saveResult.ok).toBe(true);

    // 5. Query latest - should return the latest saved rates
    const latestGst: any = await t.query(api.gst.latest, {});
    expect(latestGst).not.toBeNull();
    expect(latestGst.gold_gst).toBe(3);
    expect(latestGst.silver_gst).toBe(5);
    expect(latestGst.making_charges_gst).toBe(10);
  });
});
