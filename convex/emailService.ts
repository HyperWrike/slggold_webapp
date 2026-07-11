"use node";

import { v } from "convex/values";
import { action } from "./_generated/server";

const BREVO_SENDER_NAME = "SLG Golds";
const BREVO_SENDER_EMAIL = "otp@hyperwrike.com";

export const sendOtpEmail = action({
  args: {
    email: v.string(),
    otp: v.string(),
  },
  handler: async (_ctx, { email, otp }) => {
    const apiKey = process.env.BREVO_API_KEY;
    if (!apiKey) {
      console.warn("=================================================");
      console.warn(`MOCK EMAIL SERVICE: OTP for ${email} is [ ${otp} ]`);
      console.warn("=================================================");
      return { success: true, mock: true, messageId: "mock_id" };
    }

    const html = `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body style="margin:0;padding:0;background-color:#f5f5f5;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f5f5;padding:20px;">
      <tr>
        <td align="center">
          <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
            <!-- Gold Header -->
            <tr>
              <td style="background:linear-gradient(135deg,#B8860B,#DAA520);padding:40px 30px;text-align:center;">
                <h1 style="margin:0;color:#ffffff;font-size:28px;letter-spacing:2px;font-weight:700;">SLG GOLDS</h1>
                <p style="margin:8px 0 0;color:rgba(255,255,255,0.9);font-size:14px;">Your Trusted Gold Partner</p>
              </td>
            </tr>
            <!-- Body -->
            <tr>
              <td style="padding:40px 30px;">
                <h2 style="margin:0 0 8px;color:#333333;font-size:22px;">Verification Code</h2>
                <p style="margin:0 0 24px;color:#666666;font-size:15px;line-height:1.6;">Use the OTP below to complete your verification. This code is valid for <strong style="color:#B8860B;">5 minutes</strong>.</p>
                <!-- OTP Box -->
                <table cellpadding="0" cellspacing="0" style="margin:0 auto 32px;">
                  <tr>
                    <td style="background-color:#fdf8ed;border:2px dashed #DAA520;border-radius:12px;padding:20px 40px;text-align:center;">
                      <span style="font-size:36px;font-weight:700;letter-spacing:12px;color:#B8860B;font-family:'Courier New',monospace;">${otp}</span>
                    </td>
                  </tr>
                </table>
                <p style="margin:0 0 8px;color:#999999;font-size:13px;line-height:1.5;">If you did not request this code, please ignore this email or contact support.</p>
                <p style="margin:0;color:#999999;font-size:13px;">This is an automated message from SLG Golds. Please do not reply.</p>
              </td>
            </tr>
            <!-- Footer -->
            <tr>
              <td style="background-color:#fafafa;padding:20px 30px;text-align:center;border-top:1px solid #eeeeee;">
                <p style="margin:0 0 4px;color:#999999;font-size:12px;">&copy; ${new Date().getFullYear()} SLG Golds. All rights reserved.</p>
                <p style="margin:0;color:#cccccc;font-size:11px;">hyperwrike.com</p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`;

    const response = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "accept": "application/json",
        "api-key": apiKey,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        sender: {
          name: BREVO_SENDER_NAME,
          email: BREVO_SENDER_EMAIL,
        },
        to: [
          { email, name: email.split("@")[0] },
        ],
        subject: "Your SLG Golds OTP Code",
        htmlContent: html,
      }),
    });

    const body = await response.json();

    if (!response.ok) {
      throw new Error(
        `Failed to send email: ${body.message ?? response.statusText}`,
      );
    }

    return { success: true, messageId: body.messageId };
  },
});
