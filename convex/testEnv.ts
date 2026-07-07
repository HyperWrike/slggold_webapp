"use node";

import { v } from "convex/values";
import { action } from "./_generated/server";

export const test = action({
  args: {},
  handler: async () => {
    const apiKey = process.env.BREVO_API_KEY;
    const response = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "accept": "application/json",
        "api-key": apiKey!,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        sender: { name: "Test", email: "otp@hyperwrike.com" },
        to: [{ email: "kaliyugiheart@gmail.com" }],
        subject: "Test",
        htmlContent: "<p>test</p>",
      }),
    });
    const body = await response.json();
    return { status: response.status, ok: response.ok, body };
  },
});
