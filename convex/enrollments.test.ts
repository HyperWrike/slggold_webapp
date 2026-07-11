import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("enrollments", () => {
  test("enrollment CRUD and admin endpoints", async () => {
    const t = convexTest(schema);

    // 1. Setup mock profiles, sessions, and a scheme
    const { adminToken, customerToken, customerUserId, schemeId } = await t.run(async (ctx) => {
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

      const sId = await ctx.db.insert("schemes", {
        name: "Standard Gold",
        metal_type: "gold",
        monthly_amount: 1000,
        tenure_months: 11,
        is_active: true,
        created_at: new Date().toISOString(),
      });

      return {
        adminToken: adminSessionToken,
        customerToken: customerSessionToken,
        customerUserId: customerId,
        schemeId: sId,
      };
    });

    // 2. Try list enrollments for user - should be empty initially
    const initialList: any = await t.query(api.enrollments.listForUserWithSchemes, {
      sessionToken: customerToken,
    });
    expect(initialList.length).toBe(0);

    // 3. Create enrollment
    const createResult = await t.mutation(api.enrollments.create, {
      sessionToken: customerToken,
      schemeId,
      monthlyAmount: 1000,
      tenureMonths: 11,
    });
    expect(createResult.ok).toBe(true);
    expect(createResult.id).toBeDefined();

    // 4. List enrollments for user again - should have 1 item
    const listAfterEnroll: any = await t.query(api.enrollments.listForUserWithSchemes, {
      sessionToken: customerToken,
    });
    expect(listAfterEnroll.length).toBe(1);
    expect(listAfterEnroll[0].monthly_amount).toBe(1000);
    expect(listAfterEnroll[0].schemes).not.toBeNull();
    expect(listAfterEnroll[0].schemes.name).toBe("Standard Gold");

    // 5. Try accessing admin reporting endpoint as customer - should throw Forbidden
    await expect(
      t.query(api.enrollments.listAllForReports, {
        sessionToken: customerToken,
      })
    ).rejects.toThrow("Forbidden");

    // 6. List all for reports as admin - should succeed
    const allReports: any = await t.query(api.enrollments.listAllForReports, {
      sessionToken: adminToken,
    });
    expect(allReports.length).toBe(1);

    // 7. Get specific user enrollments as admin
    const customerEnrollments: any = await t.query(api.enrollments.listForCustomerUserId, {
      sessionToken: adminToken,
      customerUserId: String(customerUserId),
    });
    expect(customerEnrollments.length).toBe(1);
    expect(customerEnrollments[0].monthly_amount).toBe(1000);

    // 8. Try accessing countActiveForScheme as customer - should throw Forbidden
    await expect(
      t.query(api.enrollments.countActiveForScheme, {
        sessionToken: customerToken,
        schemeId,
      })
    ).rejects.toThrow("Forbidden");

    // 9. Get count as admin
    const activeCount = await t.query(api.enrollments.countActiveForScheme, {
      sessionToken: adminToken,
      schemeId,
    });
    expect(activeCount).toBe(1);
  });
});
