# Development Rules & Conventions: SLG Golds

## Tech Stack (Mandatory)
- **Framework**: Flutter (latest stable) for Android & iOS.
- **Language**: Dart exclusively. No Kotlin/Swift native code bridging unless absolutely required.
- **Backend & Database**: Supabase via MCP Server. Use Supabase for Auth, PostgreSQL, Realtime, and Storage.
- **State Management**: Riverpod (HookRiverpod / AsyncNotifier). Code must be strictly predictable.
- **Navigation**: `go_router` for deep linking, param passing, and shell routing.
- **Network**: `http` package for GoldAPI calls.
- **Local Storage**: `flutter_secure_storage` for PIN caching and secure tokens. `shared_preferences` for non-sensitive data (e.g., theme, onboarding shown).
- **Authentication**: `local_auth` for Biometric implementations.
- **UI/Animation**: `lottie` for splash and success animations, `shimmer` for skeleton loading states.
- **Formatting**: `intl` for INR currency, grammatical number formatting, and Indian date formats (dd/MM/yyyy).

## Architecture Rules (Clean Architecture)
- **Strict Layering**: `lib/data/` (Datasources, Models, Repositories Impl), `lib/domain/` (Entities, UseCases, Repositories Interfaces), `lib/presentation/` (Screens, Providers, Widgets).
- **No UI Business Logic**: Widgets handle layout and input ONLY. Logic resides in UseCases or Riverpod Notifiers.
- **Supabase Isolation**: Never make direct `Supabase.instance.client` calls from UI widgets. Data flows from UI → Provider → UseCase → Repository → DataSource.
- **Screen Structure**:
  - `/lib/presentation/screens/[screen_name]/[screen_name]_screen.dart`
  - `/lib/presentation/screens/[screen_name]/[screen_name]_controller.dart` (Riverpod Provider Notifier)
  - `/lib/presentation/screens/[screen_name]/widgets/` (Sub-components)

## Naming Conventions
- **Files/Folders**: `snake_case.dart`
- **Classes/Enums**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: Prefixed with `k` e.g., `kConstantName` (or static const within classes like `AppColors.goldPrimary`).
- **Providers**: Suffixed with `Provider` e.g., `goldPriceProvider`, `profileNotifierProvider`.
- **Routes**: Clean slashes e.g., `/onboarding`, `/home`, `/admin/dashboard`.

## Supabase Rules (via MCP)
- **Schema Validation**: Always check MCP server tools prior to assuming a schema or writing a query.
- **Error Handling**: Wrap every single Supabase network call in `try/catch` blocks mapping to custom typed `AppException` boundaries.
- **RLS (Row Level Security)**: Essential. The DB dictates security. Customers can only view/edit rows where `customer_id == auth.uid()`.
- **Admin Verification**: Role is verified via `profiles.role = 'admin'` from the DB, do not trust client-side local cache alone.
- **Secrets Management**: Never commit Supabase anon keys or URIs. Use `flutter_dotenv` (`.env` file).

## UI Rules
- **Color Palette**: Strict avoidance of hardcoded hex values. Reference `AppColors`.
- **Typography/Strings**: Pull text from `AppStrings` constants. No magic strings in UI files.
- **Formatting**:
  - Currency: Precede with ₹ symbol and 2 decimal places (e.g., ₹ 2,345.50).
  - Grams: Suffix with 'g' and exactly 4 decimal places (e.g., 2.1035 g).
- **Screen States**: Every data-driven screen must implement:
  - `Loading` (Shimmer skeletons, NO circular progress indicators for main content).
  - `Error` (Branded error illustration + text + Retry button).
  - `Empty` (Branded illustration + contextual message).
- **Form Validation**: Trigger validators both `onSubmit` and `onChange` (after the first failed submit).
- **Haptics**: Implement `HapticFeedback.lightImpact()` on PIN digits, tab changes; `HapticFeedback.mediumImpact()` on success actions, heavy for errors.

## Security Rules
- **Aadhaar Protection**: Encrypt Aadhaar upon entry. Decrypt only into masked formats for UI (`XXXX-XXXX-1234`).
- **PIN Hashing**: PIN is never stored in plain text. Secure hash generated (bcrypt via Edge Function / DB crypto). Client stores PIN securely in KeyStore/Keychain for local auth.
- **No Console Leaks**: Disable print statements for sensitive payload data (tokens, PINs, PII) in production.
- **Biometrics**: Biometric prompt only accessible AFTER a user has set up a PIN. Biometrics acts as a PIN replacement (convenience), not an Auth replacement.

## Testing Rules
- **Domain**: Every `UseCase` must have a unit test verifying business logic (e.g., GST calculation, scheme eligibility).
- **Data**: Every `Repository` must have an injected mock test verifying data mapping from Datasource to Entity.
- **Presentation**: Widget tests required for complex flows (Registration validation, PIN entry mechanics, Enrollment state changes).
- **Integration**: Minimum 2 full integration tests: (1) Complete Registration → Auto-login. (2) Scheme Enrollment → Transaction verification.

## Git Rules
- Branch names: `feature/brief-description`, `fix/issue-description`, `chore/setup-tasks`.
- Commit format: `<type>: <description>` (e.g., `feat: build live gold price cards`, `fix: correct gst precision logic`).
- Never commit `.env`, `*.lock` (unless strictly controlling versions), or keystore files.
