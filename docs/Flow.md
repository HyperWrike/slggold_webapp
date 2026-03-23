# Development Flow: SLG Golds

## Task 1: Generate all 4 docs
**Depends on:** None  
**Estimated effort:** S
### What to build:
Generate PRD.md, RULES.md, architecture.md, Flow.md thoroughly and accurately.
### Done when:
- [x] PRD created
- [x] RULES created
- [x] Architecture created
- [x] Flow created

## Task 2: Create Flutter project + set up folder structure
**Depends on:** Task 1  
**Estimated effort:** S
### What to build:
Initialize standard Flutter app, clear default boilerplate, install dependencies (`flutter_riverpod`, `go_router`, `supabase_flutter`, `http`, `flutter_secure_storage`, `lottie`, `shimmer`, `intl`), set up Clean Arch folders.
### Done when:
- [ ] `pubspec.yaml` configured with all dependencies
- [ ] Folder tree exactly matches architecture.md

## Task 3: Set up Supabase project + create tables + RLS
**Depends on:** Task 2  
**Estimated effort:** M
### What to build:
Use MCP server to execute SQL queries. Create `profiles`, `schemes`, `enrollments`, `transactions`, `gst_settings`. Set up RLS policies exactly as defined.
### Done when:
- [ ] All tables created successfully
- [ ] Foreign keys mapped
- [ ] RLS enabled on all tables

## Task 4: Configure go_router with all routes
**Depends on:** Task 2  
**Estimated effort:** S
### What to build:
Set up navigation tree: Splash, Onboarding, Auth, Main Shell (5 tabs), Admin Shell. Handle redirection guards for auth.
### Done when:
- [ ] `app_router.dart` compiles and runs
- [ ] Test navigation maps correct dummy screens

## Task 5: Build Core Constants (Theme, Colors, Strings, Dimensions)
**Depends on:** Task 2  
**Estimated effort:** S
### What to build:
Populate `core/constants/`. Define purple/gold and white premium themes.
### Done when:
- [ ] Colors conform to design spec
- [ ] Text styles mapped to DM Sans, Noto Serif, Cormorant Garamond

## Task 6: Build shared widgets
**Depends on:** Task 5  
**Estimated effort:** M
### What to build:
Create reusable UI elements: `SLGButton`, `SLGTextField`, `SLGCard`, `ShimmerLoader`, `PinPadWidget`.
### Done when:
- [ ] Widgets handle states (disabled, active, error)
- [ ] Tested visually in a gallery or scratch file

## Task 7: Build Supabase auth datasource + repository + usecase
**Depends on:** Task 3  
**Estimated effort:** L
### What to build:
Implement the data/domain layer for registration, login, logout, profile creation.
### Done when:
- [ ] Try/catch logic implemented
- [ ] Successfully logs into Supabase

## Task 8: Build Splash Screen
**Depends on:** Task 6  
**Estimated effort:** S
### What to build:
Implement Lottie animations, purple background, brand text, fade-ins.
### Done when:
- [ ] Matches HTML design timings

## Task 9: Build Customer Type Selection Screen
**Depends on:** Task 8  
**Estimated effort:** S
### What to build:
Two glass-card buttons: New Customer, Existing Customer.
### Done when:
- [ ] UI is pixel-perfect

## Task 10: Build Registration Step 1 (Personal Details)
**Depends on:** Task 9  
**Estimated effort:** M
### What to build:
Form UI and validation. Name, DOB, Age Calculation, Birthplace, Father Name, Gender.
### Done when:
- [ ] Fields validate correctly
- [ ] Age auto-calculates

## Task 11: Build Registration Step 2 (Contact & ID)
**Depends on:** Task 10  
**Estimated effort:** M
### What to build:
Address, Aadhaar (masked), Phone (OTP UI simulation).
### Done when:
- [ ] Aadhaar input masks automatically

## Task 12: Build Registration Step 3 (Nominee)
**Depends on:** Task 11  
**Estimated effort:** S
### What to build:
Nominee details form.
### Done when:
- [ ] Validated and stored in memory state

## Task 13: Build Registration Step 4 (Account Setup + PIN choice)
**Depends on:** Task 12  
**Estimated effort:** M
### What to build:
Username check, Password strength, PIN selection (4 or 6), Submit to Supabase.
### Done when:
- [ ] Profile created in DB successfully

## Task 14: Build Registration Success Screen
**Depends on:** Task 13  
**Estimated effort:** S
### What to build:
Confetti, personalized summary, auto-redirect.
### Done when:
- [ ] Successfully transitions to Home

## Task 15: Build Login Screen
**Depends on:** Task 7  
**Estimated effort:** M
### What to build:
Username/Password UI. Validates against DB.
### Done when:
- [ ] Authenticates successfully

## Task 16: Build PIN Entry Screen
**Depends on:** Task 15  
**Estimated effort:** M
### What to build:
Verification pin pad post-login.
### Done when:
- [ ] Securely matches stored PIN
- [ ] Biometric trigger available

## Task 17: Build GoldAPI datasource + metal price provider
**Depends on:** Task 2  
**Estimated effort:** M
### What to build:
Http call to GoldAPI. Riverpod `AsyncNotifier` refreshing every 60s.
### Done when:
- [ ] Returns valid XAU and XAG numbers
- [ ] Gracefully fails offline

## Task 18: Build Home Screen - metal price cards
**Depends on:** Task 17  
**Estimated effort:** M
### What to build:
Premium UI cards showing live Gold/Silver prices. Shimmer while loading.
### Done when:
- [ ] Auto-updates seamlessly

## Task 19: Build Home Screen - scheme carousel
**Depends on:** Task 18, 3  
**Estimated effort:** M
### What to build:
Realtime list of active schemes available for enrollment.
### Done when:
- [ ] Stream correctly shows DB schemes

## Task 20: Build Home Screen - portfolio summary strip
**Depends on:** Task 3  
**Estimated effort:** S
### What to build:
Top-level metrics: Total gold grams, silver grams.
### Done when:
- [ ] Calculates accurately from enrollments

## Task 21: Build Portfolio Screen - header + per-enrollment list
**Depends on:** Task 20  
**Estimated effort:** L
### What to build:
Detailed view of all enrollments. Gram calculation logic per-transaction.
### Done when:
- [ ] Formula: total amount paid / gold price at time of payment

## Task 22: Build Portfolio Screen - skip logic + cancellation UI
**Depends on:** Task 21  
**Estimated effort:** M
### What to build:
Button to "Skip a Month". Logic for 3 consecutive skips = cancelled state.
### Done when:
- [ ] DB updates correctly
- [ ] UI reflects cancelled state

## Task 23: Build Transactions Screen
**Depends on:** Task 22  
**Estimated effort:** L
### What to build:
Ledger view. Chronological list, GST deducted, net invested. Filter parameters. Receipt generation.
### Done when:
- [ ] Perfect math visualization for GST split

## Task 24: Build Scheme Enrollment - available schemes
**Depends on:** Task 19  
**Estimated effort:** M
### What to build:
List/Grid formatting of schemes.
### Done when:
- [ ] Clicking scheme opens detail sheet

## Task 25: Build Scheme Enrollment - enrolled schemes
**Depends on:** Task 24  
**Estimated effort:** S
### What to build:
Secondary tab showing what user is already in.
### Done when:
- [ ] Tab switching works

## Task 26: Build Enrollment Flow
**Depends on:** Task 24  
**Estimated effort:** L
### What to build:
Flow: input amount -> choose date -> review GST preview -> confirm PIN -> Enrolled. Create rows in DB.
### Done when:
- [ ] `enrollments` table populated accurately

## Task 27: Build GST calculation utility
**Depends on:** Task 5  
**Estimated effort:** S
### What to build:
Math functions safely handling double precision for INR.
### Done when:
- [ ] Unit tests pass for 3% deductions

## Task 28: Build Profile Screen
**Depends on:** Task 7  
**Estimated effort:** S
### What to build:
Read-only display of user data.
### Done when:
- [ ] UI is clean, Aadhaar masked

## Task 29: Build Profile Settings
**Depends on:** Task 28  
**Estimated effort:** S
### What to build:
Change PIN flow, change password edge function, logout clearing.
### Done when:
- [ ] State resets entirely on logout

## Task 30: Build Admin Login Screen
**Depends on:** Task 4  
**Estimated effort:** S
### What to build:
Alternative login page routing directly to Admin Shell.
### Done when:
- [ ] Intercepts Admin@Slggolds.com

## Task 31: Build Admin Dashboard Screen
**Depends on:** Task 3  
**Estimated effort:** M
### What to build:
Aggregate data calls. AUM calc. Recent tx scroll.
### Done when:
- [ ] Realtime stats function properly

## Task 32: Build Admin Scheme Management
**Depends on:** Task 31  
**Estimated effort:** M
### What to build:
CRUD operations for schemes.
### Done when:
- [ ] Admin can create/toggle scheme status remotely

## Task 33: Build Admin Customer List + Detail
**Depends on:** Task 32  
**Estimated effort:** L
### What to build:
List all signed-up users. Deep dive into their portfolios.
### Done when:
- [ ] RLS allows admin to view these rows

## Task 34: Build Admin GST Management
**Depends on:** Task 33  
**Estimated effort:** S
### What to build:
Read/Write to `gst_settings` table.
### Done when:
- [ ] New investments instantly use new rate

## Task 35: Build Admin Reports Screen
**Depends on:** Task 34  
**Estimated effort:** M
### What to build:
Aggregated charts/logs based on timestamps.
### Done when:
- [ ] Data correctly scopes to date ranges

## Task 36: Supabase RLS testing
**Depends on:** Task 3  
**Estimated effort:** M
### What to build:
Security audit verifying user A cannot pull user B data. Admin constraints verified.
### Done when:
- [ ] All vectors secured

## Task 37: Biometric login implementation
**Depends on:** Task 16  
**Estimated effort:** M
### What to build:
Device biometric API prompt injected into flow.
### Done when:
- [ ] Seamlessly bypasses PIN pad

## Task 38: Offline mode
**Depends on:** Task 17  
**Estimated effort:** L
### What to build:
Hive/shared_prefs caching of prices and portfolio state.
### Done when:
- [ ] App launches with airplane mode engaged

## Task 39: UI polish pass
**Depends on:** All  
**Estimated effort:** M
### What to build:
Tune haptics, hero animations, sheet drag limits.
### Done when:
- [ ] App feels unequivocally premium

## Task 40: Testing
**Depends on:** All  
**Estimated effort:** L
### What to build:
Run flutter_test. Achieve coverage.
### Done when:
- [ ] Zero failing tests

## Task 41: Release configuration
**Depends on:** Task 40  
**Estimated effort:** M
### What to build:
Set icons, splash names, package names, dot env stripping.
### Done when:
- [ ] AAB and IPA generated successfully
