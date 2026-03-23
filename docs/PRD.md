# Product Requirements Document: SLG Golds

## Executive Summary
SLG Golds is a premium gold & silver savings and investment mobile application tailored for Indian customers. It solves the problem of inaccessible, unorganized, and manually tracked precious metal savings by providing a secure, digital vault experience. Customers can monitor live prices, register securely, enroll in recurring savings schemes, and track their accumulated wealth—all with automatic GST handling, strict KYC compliance through Aadhaar, and a transparent bonus structure.

## Target Users
- **Primary:** Indian retail customers aged 22–55 looking for secure, structured, and modern gold/silver investment methods.
- **Secondary:** Admin staff of SLG Golds managing schemes, tracking collections, adjusting GST, and monitoring customer portfolios.

## User Stories
1. As a new customer, I want to register with my personal details so that I can create an account securely.
2. As a new customer, I want to provide my Aadhaar and contact details so that my identity is verified and KYC is maintained.
3. As a new customer, I want to add nominee details so that my investments are safeguarded for my family.
4. As a new customer, I want to set a secure 4 or 6-digit PIN so that only I can access my digital vault.
5. As an existing customer, I want to log in using my username and password to access my account from a new device.
6. As an existing customer, I want to enter my PIN quickly upon app open so that I have frictionless yet secure access.
7. As an existing customer, I want to use biometric authentication (Face ID / Fingerprint) so that I don't have to type my PIN every time.
8. As a customer, I want to see live gold prices (24K) updated every 60 seconds so that I can make informed investment decisions.
9. As a customer, I want to see live silver prices updated every 60 seconds so that I can track market trends.
10. As a customer, I want to view active investments and accrued grams on my home dashboard so that I have a quick summary of my wealth.
11. As a customer, I want to browse available and popular savings schemes so that I can find a plan that fits my budget.
12. As a customer, I want to see notifications about my account so that I stay updated on due dates and bonuses.
13. As a customer, I want to view my complete portfolio value in INR so that I know my current asset worth.
14. As a customer, I want to see a scheme-by-scheme breakdown of my saved grams and months paid so that I can track my progress.
15. As a customer, I want the ability to skip a payment month so that I have flexibility during tight financial months.
16. As a customer, I want to view chronological transactions with GST breakdowns so that my purchases are completely transparent.
17. As a customer, I want to tap a transaction for a full receipt view so that I can share or save it as a PDF/image.
18. As a customer, I want to filter transactions by date range or scheme so that I can find specific investments.
19. As a customer, I want to enroll in a scheme by picking an amount and date so that auto-reminders or payments are structured.
20. As a customer, I want to manage my profile and view KYC status so that I know my account is in good standing.
21. As a customer, I want to change my PIN, password, or biometric settings so that my account remains secure.
22. As an admin, I want to view a dashboard with live total customers, AUM, and today's collections so that I have a pulse on business operations.
23. As an admin, I want to create new schemes directly from the app so that customers can see and enroll in them instantly.
24. As an admin, I want to manage customers and view their portfolios so that I can handle support requests or manual overrides.
25. As an admin, I want to update the current GST rate so that the application complies with changing government regulations.
26. As an admin, I want to view reports on revenue, collections, and grams distributed so that accounting is streamlined.

## Screen Inventory
1. **SplashScreen** (/splash): Displays brand logo, Lottie animation, tagline, and "Get Started" CTA. API: None.
2. **CustomerTypeScreen** (/onboarding/customer-type): "New Customer" (to Reg) or "Existing Customer" (to Login).
3. **RegistrationStep1** (/onboarding/register/1): Personal Details (Name, DOB, Birth Place, Father's Name, Gender). Business Logic: Calculate Age from DOB.
4. **RegistrationStep2** (/onboarding/register/2): Contact & ID (Address, Aadhaar, Phone). Business Logic: Mask Aadhaar.
5. **RegistrationStep3** (/onboarding/register/3): Nominee Details (Name, Relationship).
6. **RegistrationStep4** (/onboarding/register/4): Account Setup (Username, Password, PIN Length, PIN Code, Confirm PIN). Business Logic: Hash PIN, Check Unique Username via Supabase.
7. **RegistrationSuccessScreen** (/onboarding/success): Confetti, Auto-Login logic routing to Home.
8. **LoginScreen** (/auth/login): Username and Password entry. Calls Supabase Auth.
9. **PINSetupScreen** (/auth/pin-setup): Triggered if PIN missing.
10. **PINEntryScreen** (/auth/pin-entry): 4 or 6-digit entry before accessing app. Forgot PIN OTP logic. Biometric trigger.
11. **HomeScreen** (/main/home): Greeting, Live Metal Prices (GoldAPI), Active Schemes carousel, Portfolio summary strip. API: GoldAPI.io refresh every 60s, Supabase Realtime for schemes.
12. **PortfolioScreen** (/main/portfolio): Total Value KPI (Grams × Live Price), Per-scheme card breakdown. Logic: 12th Month bonus calc, 3 skips = Cancelled.
13. **TransactionScreen** (/main/transactions): List view of all investments/bonus/refunds. GST vs Net split. Filter logic.
14. **SchemeEnrollmentScreen** (/main/schemes): Tabbed view (Available / Enrolled). Filters for scheme type.
15. **SchemeDetailSheet** (Modal): Details of scheme, T&Cs, "Start Investing" CTA.
16. **EnrollmentFlowScreen** (/main/schemes/enroll): Amount input (min ₹100), payment date picker, GST preview, PIN confirm to enroll.
17. **ProfileScreen** (/main/profile): User details, masked Aadhaar, KYC badge. Settings logic (Change PIN, toggle bio, logout). 
18. **AdminLoginScreen** (/admin/login): Hardcoded admin credential check.
19. **AdminDashboardScreen** (/admin/dashboard): Live KPIs (Customers, AUM, Today's collections, Recent txs). Realtime Supabase listener.
20. **AdminSchemeManagementScreen** (/admin/schemes): List of schemes, active/inactive toggles.
21. **AdminCreateSchemeScreen** (/admin/schemes/create): Form to create scheme (Name, min amt, duration, bonus, metal). Pushes to Supabase Realtime.
22. **AdminCustomerListScreen** (/admin/customers): Searchable list of profiles.
23. **AdminCustomerDetailScreen** (/admin/customers/:id): View single customer data/portfolio.
24. **AdminGSTManagementScreen** (/admin/gst): View/update global GST rate (default 3%). Logs changes.
25. **AdminReportsScreen** (/admin/reports): Date-range filtered metrics (Revenue, Collections).

## Business Rules
- **GST Calculation**: GST is strictly deducted BEFORE investment. Gross Amount × 3% = GST Amount. Gross - GST = Net Investment.
- **Gram Conversion**: Grams purchased = Net Investment Amount / Live Gold Price Per Gram at time of transaction. (Gold Price sent from API needs conversion if in oz: 1 troy oz = 31.1035 g, but GoldAPI provides `price_gram_24k` directly).
- **12th Month Bonus**: Upon reaching the 12th month of an active scheme, SLG pays an amount equal to 1 month's minimal payment (customer receives proportional gold based on live price).
- **Cancellation Rule**: 3 consecutive skipped monthly payments flag the scheme status to "Cancelled - Contact Support".
- **GST Exclusivity**: Admin can change the GST rate globally, but changes only apply to future transactions (historical transactions retain their recorded GST rate).
- **PIN Requirements**: Customer can select either a 4-digit or 6-digit PIN during Registration Step 4.

## API Integrations
- **GoldAPI.io**:
  - Gold: `GET https://www.goldapi.io/api/XAU/INR`
  - Silver: `GET https://www.goldapi.io/api/XAG/INR`
  - Header: `x-access-token: goldapi-31wrs0hsmmxhhj94-io`
  - Polling: Every 60 seconds.
  - Required Field: `price_gram_24k`.
- **Supabase (MCP)**:
  - Auth: Native email/password auth disguised as username (or custom auth schema). 
  - Database: `profiles`, `schemes`, `enrollments`, `transactions`, `gst_settings`.
  - Realtime: Listen to `schemes` table for live updates on Home Screen. Listen to `transactions` for Admin Dashboard.

## Non-Functional Requirements
- **Performance**: Gold price refreshes smoothly without blocking UI (≤ 60s). App load time < 2s.
- **Security**: Aadhaar numbers encrypted at rest in Supabase. PINs strictly bcrypt hashed (never plain text). RLS policies ensure customers see only their own `user_id` mapped rows. Admin routes require strict role verification.
- **Offline Capabilities**: If GoldAPI fails or user is offline, show last cached prices with a clear "Last Updated: [Time]" warning banner.

## Out of Scope (v1)
- Payment Gateway integration (transactions are assumed manually collected or bank transferred outside the app, but recorded digitally by customer/admin).
- UPI/Bank linking.
- Physical gold delivery tracking workflows.
