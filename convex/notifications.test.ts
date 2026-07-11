import { describe, expect, test } from "vitest";
import { convexTest } from "convex-test";
import schema from "./schema";
import { api } from "./_generated/api";

describe("notifications", () => {
  test("notification listing, marking as read, and admin creation", async () => {
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

    // 2. Query empty notifications
    const initialUnread: any = await t.query(api.notifications.listUnread, {
      sessionToken: customerToken,
    });
    expect(initialUnread.length).toBe(0);

    // 3. Try to create notification as customer - should throw Forbidden
    await expect(
      t.mutation(api.notifications.create, {
        sessionToken: customerToken,
        userId: String(customerUserId),
        title: "Test",
        message: "Hello world",
      })
    ).rejects.toThrow("Forbidden");

    // 4. Create user-specific notification as admin
    const createRes1 = await t.mutation(api.notifications.create, {
      sessionToken: adminToken,
      userId: String(customerUserId),
      title: "Welcome",
      message: "Welcome to SLG Golds",
      notifType: "info",
    });
    expect(createRes1.ok).toBe(true);

    // 5. Create global notification as admin
    const createRes2 = await t.mutation(api.notifications.create, {
      sessionToken: adminToken,
      title: "Global Promo",
      message: "Big discounts on silver!",
      notifType: "promo",
      isGlobal: true,
    });
    expect(createRes2.ok).toBe(true);

    // 6. Query listForUser - should contain both welcome and global promo
    const userNotifs: any = await t.query(api.notifications.listForUser, {
      sessionToken: customerToken,
    });
    expect(userNotifs.length).toBe(2);
    
    // Welcome notification should be user-specific
    const welcomeNotif = userNotifs.find((n: any) => n.title === "Welcome");
    expect(welcomeNotif).toBeDefined();
    expect(welcomeNotif.user_id).toBe(String(customerUserId));

    // Global promo should be global
    const globalNotif = userNotifs.find((n: any) => n.title === "Global Promo");
    expect(globalNotif).toBeDefined();
    expect(globalNotif.is_global).toBe(true);

    // 7. Test markRead for welcome notification
    const markReadRes = await t.mutation(api.notifications.markRead, {
      sessionToken: customerToken,
      notificationId: welcomeNotif.id,
    });
    expect(markReadRes.ok).toBe(true);

    // List unread should now only have the global notification since it's not marked read yet (Wait, is_global notifications don't get individually patched as read, or do they? Wait, markRead patches user_id matches. In listUnread it checks is_read !== true && user_id === userId. Welcome was user_id === userId, now is_read = true. So welcome notification is read.)
    const unreadAfterMark: any = await t.query(api.notifications.listUnread, {
      sessionToken: customerToken,
    });
    expect(unreadAfterMark.length).toBe(0); // since global promo user_id is undefined (it's global), listUnread only returns row.user_id === userId and is_read !== true.

    // 8. Add another unread notification
    await t.mutation(api.notifications.create, {
      sessionToken: adminToken,
      userId: String(customerUserId),
      title: "Alert",
      message: "Urgent action required",
      notifType: "alert",
    });

    const unreadList: any = await t.query(api.notifications.listUnread, {
      sessionToken: customerToken,
    });
    expect(unreadList.length).toBe(1);
    expect(unreadList[0].title).toBe("Alert");

    // 9. Test markAllRead
    const markAllRes = await t.mutation(api.notifications.markAllRead, {
      sessionToken: customerToken,
    });
    expect(markAllRes.ok).toBe(true);

    const finalUnread: any = await t.query(api.notifications.listUnread, {
      sessionToken: customerToken,
    });
    expect(finalUnread.length).toBe(0);
  });
});
