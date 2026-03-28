import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/dummy_screens.dart';
import '../../presentation/screens/onboarding/splash_screen.dart'
    as real_splash;
import '../../presentation/screens/onboarding/customer_type_screen.dart'
    as real_customer_type;
import '../../presentation/screens/onboarding/registration/registration_step1_screen.dart';
import '../../presentation/screens/onboarding/registration/registration_step2_screen.dart';
import '../../presentation/screens/onboarding/registration/registration_step3_screen.dart';
import '../../presentation/screens/onboarding/registration/registration_step4_screen.dart';
import '../../presentation/screens/onboarding/registration/registration_success_screen.dart'
    as real_success;
import '../../presentation/screens/auth/login_screen.dart' as real_login;
import '../../presentation/screens/auth/pin_entry_screen.dart'
    as real_pin_entry;
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/main/home/home_screen.dart' as real_home;
import '../../presentation/screens/main/portfolio/portfolio_screen.dart'
    as real_portfolio;
import '../../presentation/screens/main/transactions/transaction_screen.dart'
    as real_transaction;
import '../../presentation/screens/main/schemes/scheme_enrollment_screen.dart'
    as real_schemes;
import '../../presentation/screens/main/schemes/enrollment_flow_screen.dart'
    as real_enrollment;
import '../../presentation/screens/main/profile/profile_screen.dart'
    as real_profile;
import '../../presentation/screens/admin/admin_login_screen.dart'
    as real_admin_login;
import '../../presentation/screens/admin/admin_dashboard_screen.dart'
    as real_admin_dashboard;
import '../../presentation/screens/admin/admin_scheme_list_screen.dart'
    as real_admin_schemes;
import '../../presentation/screens/admin/admin_create_scheme_screen.dart'
    as real_admin_create_scheme;
import '../../presentation/screens/admin/admin_customer_list_screen.dart'
    as real_admin_customers;
import '../../presentation/screens/admin/admin_customer_detail_screen.dart'
    as real_admin_customer_detail;
import '../../presentation/screens/admin/admin_gst_screen.dart'
    as real_admin_gst;
import '../../presentation/screens/admin/admin_reports_screen.dart'
    as real_admin_reports;

// Keys for shell routing
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _mainShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'mainShell');
final GlobalKey<NavigatorState> _adminShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminShell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const real_splash.SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/customer-type',
      builder: (context, state) =>
          const real_customer_type.CustomerTypeScreen(),
    ),
    GoRoute(
      path: '/onboarding/register/step1',
      builder: (context, state) => const RegistrationStep1Screen(),
    ),
    GoRoute(
      path: '/onboarding/register/step2',
      builder: (context, state) => const RegistrationStep2Screen(),
    ),
    GoRoute(
      path: '/onboarding/register/step3',
      builder: (context, state) => const RegistrationStep3Screen(),
    ),
    GoRoute(
      path: '/onboarding/register/step4',
      builder: (context, state) => const RegistrationStep4Screen(),
    ),
    GoRoute(
      path: '/onboarding/verify-otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpVerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/onboarding/register',
      redirect: (context, state) => '/onboarding/register/step1',
    ),
    GoRoute(
      path: '/onboarding/success',
      builder: (context, state) =>
          const real_success.RegistrationSuccessScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const real_login.LoginScreen(),
    ),
    GoRoute(
      path: '/auth/pin-setup',
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: '/auth/pin-entry',
      builder: (context, state) => const real_pin_entry.PinEntryScreen(),
    ),

    // Main App Shell
    ShellRoute(
      navigatorKey: _mainShellNavigatorKey,
      builder: (context, state, child) {
        return MainShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const real_home.HomeScreen(),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (context, state) => const real_portfolio.PortfolioScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) =>
              const real_transaction.TransactionScreen(),
        ),
        GoRoute(
          path: '/schemes',
          builder: (context, state) =>
              const real_schemes.SchemeEnrollmentScreen(),
          routes: [
            GoRoute(
              path: 'enroll',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) =>
                  const real_enrollment.EnrollmentFlowScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const real_profile.ProfileScreen(),
        ),
      ],
    ),

    // Admin App Shell
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const real_admin_login.AdminLoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _adminShellNavigatorKey,
      builder: (context, state, child) {
        return AdminShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) =>
              const real_admin_dashboard.AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/schemes',
          builder: (context, state) =>
              const real_admin_schemes.AdminSchemeListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) =>
                  const real_admin_create_scheme.AdminCreateSchemeScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/admin/customers',
          builder: (context, state) =>
              const real_admin_customers.AdminCustomerListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return real_admin_customer_detail.AdminCustomerDetailScreen(
                  customerId: id,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/admin/gst',
          builder: (context, state) => const real_admin_gst.AdminGstScreen(),
        ),
        GoRoute(
          path: '/admin/reports',
          builder: (context, state) =>
              const real_admin_reports.AdminReportsScreen(),
        ),
      ],
    ),
  ],
);
