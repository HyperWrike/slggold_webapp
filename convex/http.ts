import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

const privacyHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Privacy Policy - SLG Golds</title>
  <style>
    body { font-family: sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #333; }
    h1 { color: #B8860B; }
    h2 { color: #DAA520; }
  </style>
</head>
<body>
  <h1>Privacy Policy for SLG Golds</h1>
  <p>Last updated: July 07, 2026</p>
  <p>Your privacy is important to us. It is SLG Golds' policy to respect your privacy regarding any information we may collect from you through our app, SLG Golds.</p>
  <h2>1. Information We Collect</h2>
  <p>We collect personal information such as name, phone number, email address, DOB, address, Aadhaar details (encrypted at rest), and nominee details to facilitate our gold and silver savings plans and verify your identity under KYC guidelines.</p>
  <h2>2. How We Use Information</h2>
  <p>We use your information to manage your account, process scheme enrollments, complete transaction history, and communicate metal rate updates, reminders, and notifications.</p>
  <h2>3. Security</h2>
  <p>Aadhaar details are stored with military-grade encryption (AES-256-GCM). PINs and passwords are securely hashed before saving.</p>
  <h2>4. Contact Us</h2>
  <p>If you have any questions about our privacy policy, contact us at privacy@slggolds.com.</p>
</body>
</html>
`;

const termsHtml = `
<!DOCTYPE html>
<html>
<head>
  <title>Terms of Service - SLG Golds</title>
  <style>
    body { font-family: sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #333; }
    h1 { color: #B8860B; }
    h2 { color: #DAA520; }
  </style>
</head>
<body>
  <h1>Terms of Service</h1>
  <p>Last updated: July 07, 2026</p>
  <p>By using the SLG Golds app, you agree to comply with and be bound by the following terms of service.</p>
  <h2>1. Investment Rules</h2>
  <p>GST is strictly deducted before any investment is locked in. Purchased grams are calculated based on the net investment and live market rates retrieved at the time of transaction.</p>
  <h2>2. Bonus Structure</h2>
  <p>On completion of a 12-month savings scheme, SLG pays a loyalty bonus equivalent to one minimal month's payment, credited as proportional gold/silver grams based on live prices.</p>
  <h2>3. Cancellation Policy</h2>
  <p>Three consecutive skipped monthly payments will cause the scheme to be flagged as Cancelled. Please contact support to resolve any collection issues.</p>
  <h2>4. Governing Law</h2>
  <p>These terms are governed by the laws of India and subject to local jurisdiction.</p>
</body>
</html>
`;

http.route({
  path: "/privacy-policy",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    return new Response(privacyHtml, {
      status: 200,
      headers: {
        "content-type": "text/html; charset=utf-8",
        "access-control-allow-origin": "*",
      },
    });
  }),
});

http.route({
  path: "/terms-of-service",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    return new Response(termsHtml, {
      status: 200,
      headers: {
        "content-type": "text/html; charset=utf-8",
        "access-control-allow-origin": "*",
      },
    });
  }),
});

export default http;
