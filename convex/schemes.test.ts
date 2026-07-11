import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("schemes", () => {
  test("schemes CRUD operations and validation", async () => {
    const t = convexTest(schema);

    // 1. Setup mock profiles and sessions
    const { adminToken, customerToken, customerUserId } = await t.run(async (ctx) => {
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
        customerUserId: customerId,
      };
    });

    // 2. Try creating a scheme as customer - should throw Forbidden
    await expect(
      t.mutation(api.schemes.create, {
        sessionToken: customerToken,
        name: "Gold Standard",
        description: "Standard Gold scheme",
        metal_type: "gold",
        monthly_amount: 1000,
        min_amount: 1000,
        tenure_months: 11,
        benefit: "1 month bonus",
        is_popular: true,
      })
    ).rejects.toThrow("Forbidden");

    // 3. Create a scheme as admin - should succeed
    const createResult = await t.mutation(api.schemes.create, {
      sessionToken: adminToken,
      name: "Gold Standard",
      description: "Standard Gold scheme",
      metal_type: "gold",
      monthly_amount: 1000,
      min_amount: 1000,
      tenure_months: 11,
      benefit: "1 month bonus",
      is_popular: true,
    });
    expect(createResult.ok).toBe(true);

    // 4. List active schemes - should return the newly created scheme
    const activeSchemes: any = await t.query(api.schemes.listActive, {});
    expect(activeSchemes.length).toBe(1);
    expect(activeSchemes[0].name).toBe("Gold Standard");
    const schemeId = activeSchemes[0].id;

    // 5. Get scheme by id
    const singleScheme: any = await t.query(api.schemes.get, { id: schemeId });
    expect(singleScheme).not.toBeNull();
    expect(singleScheme.name).toBe("Gold Standard");

    // 6. Toggle status to inactive as admin
    await t.mutation(api.schemes.toggleStatus, {
      sessionToken: adminToken,
      schemeId,
      isActive: false,
    });

    // 7. List active schemes again - should now be empty
    const activeSchemesAfterToggle: any = await t.query(api.schemes.listActive, {});
    expect(activeSchemesAfterToggle.length).toBe(0);

    // 8. Try to remove the scheme when it has an active enrollment - should throw
    await t.run(async (ctx) => {
      // Simulate active enrollment
      await ctx.db.insert("enrollments", {
        user_id: customerUserId,
        scheme_id: schemeId,
        monthly_amount: 1000,
        tenure_months: 11,
        paid_months: 1,
        paid_amount: 1000,
        status: "active",
        created_at: new Date().toISOString(),
      });
    });

    await expect(
      t.mutation(api.schemes.remove, {
        sessionToken: adminToken,
        schemeId,
      })
    ).rejects.toThrow(/Cannot delete/);

    // Clean up enrollment (cancel/pause or delete it) to allow deletion
    await t.run(async (ctx) => {
      const enr = await ctx.db
        .query("enrollments")
        .withIndex("by_scheme", (q) => q.eq("scheme_id", schemeId))
        .first();
      await ctx.db.delete(enr!._id);
    });

    // 9. Remove scheme - should now succeed
    const removeResult = await t.mutation(api.schemes.remove, {
      sessionToken: adminToken,
      schemeId,
    });
    expect(removeResult.ok).toBe(true);

    // Get deleted scheme - should return null
    const singleSchemeAfterDelete = await t.query(api.schemes.get, { id: schemeId });
    expect(singleSchemeAfterDelete).toBeNull();
  });
});
