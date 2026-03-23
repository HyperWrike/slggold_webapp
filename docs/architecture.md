# System Architecture: SLG Golds

## Folder Structure
```text
lib/
├── main.dart
├── app.dart                         # Root app widget, router setup
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_text_styles.dart
│   │   └── app_dimensions.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart          # go_router configuration
│   ├── utils/
│   │   ├── gst_calculator.dart
│   │   ├── gold_calculator.dart
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── errors/
│       └── app_exception.dart
├── data/
│   ├── datasources/
│   │   ├── supabase_auth_datasource.dart
│   │   ├── supabase_profile_datasource.dart
│   │   ├── supabase_scheme_datasource.dart
│   │   ├── supabase_enrollment_datasource.dart
│   │   ├── supabase_transaction_datasource.dart
│   │   └── metal_price_datasource.dart    # GoldAPI calls
│   ├── models/
│   │   ├── profile_model.dart
│   │   ├── scheme_model.dart
│   │   ├── enrollment_model.dart
│   │   ├── transaction_model.dart
│   │   └── metal_price_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── profile_repository_impl.dart
│       ├── scheme_repository_impl.dart
│       ├── enrollment_repository_impl.dart
│       ├── transaction_repository_impl.dart
│       └── metal_price_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── profile.dart
│   │   ├── scheme.dart
│   │   ├── enrollment.dart
│   │   ├── transaction.dart
│   │   └── metal_price.dart
│   ├── repositories/        # abstract interfaces
│   │   ├── i_auth_repository.dart
│   │   ├── i_profile_repository.dart
│   │   ├── i_scheme_repository.dart
│   │   ├── i_enrollment_repository.dart
│   │   ├── i_transaction_repository.dart
│   │   └── i_metal_price_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── register_customer_usecase.dart
│       │   ├── login_usecase.dart
│       │   └── verify_pin_usecase.dart
│       ├── schemes/
│       │   ├── get_active_schemes_usecase.dart
│       │   └── enroll_in_scheme_usecase.dart
│       ├── portfolio/
│       │   └── get_portfolio_usecase.dart
│       ├── transactions/
│       │   └── get_transactions_usecase.dart
│       └── admin/
│           ├── create_scheme_usecase.dart
│           ├── update_gst_usecase.dart
│           └── get_dashboard_stats_usecase.dart
└── presentation/
    ├── providers/           # Riverpod providers
    │   ├── auth_provider.dart
    │   ├── profile_provider.dart
    │   ├── metal_price_provider.dart
    │   ├── schemes_provider.dart
    │   ├── enrollment_provider.dart
    │   ├── transaction_provider.dart
    │   └── admin_provider.dart
    ├── screens/
    │   ├── onboarding/
    │   │   ├── splash_screen.dart
    │   │   ├── customer_type_screen.dart
    │   │   ├── registration/
    │   │   │   ├── registration_screen.dart     # Multi-step controller
    │   │   │   ├── step1_personal_details.dart
    │   │   │   ├── step2_contact_id.dart
    │   │   │   ├── step3_nominee.dart
    │   │   │   └── step4_account_setup.dart
    │   │   └── registration_success_screen.dart
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   ├── pin_setup_screen.dart
    │   │   └── pin_entry_screen.dart
    │   ├── main/
    │   │   └── main_shell_screen.dart          # Bottom nav shell
    │   ├── home/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   │       ├── metal_price_card.dart
    │   │       ├── scheme_carousel.dart
    │   │       └── portfolio_summary_strip.dart
    │   ├── portfolio/
    │   │   ├── portfolio_screen.dart
    │   │   └── widgets/
    │   │       ├── portfolio_header_card.dart
    │   │       └── enrollment_detail_card.dart
    │   ├── transactions/
    │   │   ├── transaction_screen.dart
    │   │   └── widgets/
    │   │       └── transaction_list_item.dart
    │   ├── schemes/
    │   │   ├── scheme_enrollment_screen.dart
    │   │   ├── scheme_detail_sheet.dart
    │   │   └── enrollment_flow_screen.dart
    │   ├── profile/
    │   │   └── profile_screen.dart
    │   └── admin/
    │       ├── admin_login_screen.dart
    │       ├── admin_shell_screen.dart
    │       ├── dashboard/
    │       │   └── admin_dashboard_screen.dart
    │       ├── schemes/
    │       │   ├── admin_scheme_list_screen.dart
    │       │   └── admin_create_scheme_screen.dart
    │       ├── customers/
    │       │   ├── admin_customer_list_screen.dart
    │       │   └── admin_customer_detail_screen.dart
    │       ├── gst/
    │       │   └── admin_gst_screen.dart
    │       └── reports/
    │           └── admin_reports_screen.dart
    └── widgets/             # Shared widgets
        ├── slg_button.dart          # Gold gradient CTA button
        ├── slg_text_field.dart      # Custom input field
        ├── slg_card.dart            # Base card widget
        ├── shimmer_loader.dart
        ├── error_state_widget.dart
        ├── empty_state_widget.dart
        └── pin_pad_widget.dart
```

## Data Flow Diagram
`Widget UI (Presentation)` → `Riverpod State/Notifier` → `UseCase (Domain)` → `Repository Interface (Domain)` → `Repository Implementation (Data)` → `DataSource (Data)` → `Supabase API / GoldAPI`

## Authentication Flow
1. **Registration**: Multi-step form validates inputs locally. 
2. **Supabase Auth**: Submit credentials → Supabase creates Auth User. 
3. **Profile Creation**: Insert row into `profiles` table linked to user UUID. 
4. **PIN Setup**: Client sets 4/6 digit PIN, hashed and pushed to DB, plain PIN stored in Secure Storage.
5. **Auto-Login**: Client token saved. Route to `/main/home`.
6. **Subsequent Launches**: App loads `/auth/pin-entry`. User inputs PIN. Biometric API offered if enabled. Verified → route to `/main/home`.
7. **Password Fallback**: "Forgot PIN" requires OTP via SMS/Email to reset.

## Realtime Architecture
- **Supabase Realtime** initialized globally.
- `schemes_provider`: Subscribes to `public:schemes`. Any admin dashboard creation/update seamlessly re-emits a state update onto the customer's Home Screen carousel.
- `admin_provider`: Subscribes to `public:transactions`. As customers enroll/pay, the admin dashboard updates Today's Collection and AUM instantly.

## State Management Map (Riverpod)
- `auth_provider`: User auth session, login state, PIN validation state.
- `profile_provider`: Current logged-in user's profile entity (`full_name`, `age`, KYC).
- `metal_price_provider`: `AsyncNotifier` wrapping GoldAPI. Sets a 60s `Timer.periodic` to refresh `MetalPrice` entity (Gold/Silver).
- `schemes_provider`: List of active `Scheme`s fetched from DB. Realtime stream.
- `enrollment_provider`: Customer's specific active enrollments and skip counts.
- `transaction_provider`: Chronological ledger mapped to customer UUID.
- `admin_provider`: Aggregate business data, customer lists, scheme mutation states.

## Security Architecture
- **RLS (Row Level Security)**: 
  - `profiles`: `SELECT`, `UPDATE` where `id = auth.uid()`.
  - `transactions`: `SELECT` where `customer_id = auth.uid()`.
  - `schemes`: `SELECT` for all public users, `INSERT/UPDATE/DELETE` strictly where `auth.uid() IN (SELECT id FROM profiles WHERE role='admin')`.
- **Admin Role Enforcement**: Supabase prevents malicious writes. Admin paths in `go_router` wrapped in a redirect guard checking `profileProvider.value?.role == 'admin'`.
- **PIN Handling**: Handled locally via `flutter_secure_storage` for seamless unlock. Syncs a hash to DB for absolute cross-device verification if needed.
