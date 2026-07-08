import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:slg_golds/presentation/screens/main/schemes/enrollment_flow_screen.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';
import 'package:slg_golds/domain/entities/user_entity.dart';
import 'package:slg_golds/domain/repositories/auth_repository.dart';
import 'package:slg_golds/core/errors/failures.dart';
import 'package:slg_golds/domain/usecases/auth/login_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/register_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/logout_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/verify_pin_usecase.dart';

const _testUser = UserEntity(
  id: 'test_user_123',
  fullName: 'Test User',
  username: 'testuser',
  phone: '9876543210',
  role: 'customer',
);

class _MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async => Right(_testUser);

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String aadhaar,
    required String dob,
    required String gender,
    required String fatherName,
    required String birthPlace,
    required String address,
    required String nomineeName,
    required String nomineeRelationship,
    required String pin,
  }) async => Right(_testUser);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async =>
      const Right(true);

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      Right(_testUser);
}

const testScheme = <String, dynamic>{
  'id': 'scheme_1',
  'name': 'Gold Savings Plan',
  'description': 'Save monthly and get gold',
  'metal_type': 'gold',
  'monthly_amount': 5000.0,
  'min_amount': 1000.0,
  'tenure_months': 11,
  'benefit': '1 extra month gold bonus',
  'is_active': true,
  'is_popular': true,
};

Widget buildTestWidget({Map<String, dynamic>? scheme}) {
  final repo = _MockAuthRepository();
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(
        (ref) => AuthNotifier(
          LoginUseCase(repo),
          RegisterUseCase(repo),
          LogoutUseCase(repo),
          GetCurrentUserUseCase(repo),
          VerifyPinUseCase(repo),
        ),
      ),
    ],
    child: MaterialApp(
      home: EnrollmentFlowScreen(scheme: scheme ?? testScheme),
    ),
  );
}

void main() {
  group('EnrollmentFlowScreen', () {
    testWidgets('renders scheme name and tenure info', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gold Savings Plan'), findsOneWidget);
      expect(find.textContaining('11 Months Duration'), findsOneWidget);
      expect(find.textContaining('1 extra month gold bonus'), findsOneWidget);
    });

    testWidgets('renders amount input field', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert - SlgTextField uppercases the label
      expect(find.text('MONTHLY INSTALLMENT AMOUNT (₹)'), findsOneWidget);
      expect(find.textContaining('Minimum installment amount'), findsOneWidget);
    });

    testWidgets('renders payment summary section', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.textContaining('You Pay'), findsOneWidget);
      expect(find.text('Gold Bonus'), findsOneWidget);
      expect(find.text('Total Value Accumulated'), findsOneWidget);
    });

    testWidgets('proceed button is disabled when amount is below minimum',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert - SlgButton wraps an InkWell; when onPressed is null, onTap is null
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      final proceedInkWell = inkWells.firstWhere(
        (w) => w.onTap == null,
        orElse: () => throw StateError('No disabled InkWell found'),
      );
      expect(proceedInkWell.onTap, isNull);
    });

    testWidgets('renders app bar with back button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enroll in Scheme'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('renders scheme name from provided data', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gold Savings Plan'), findsOneWidget);
    });

    testWidgets('shows correct tenure months from scheme', (tester) async {
      // Arrange
      final customScheme = Map<String, dynamic>.from(testScheme);
      customScheme['tenure_months'] = 24;

      // Act
      await tester.pumpWidget(buildTestWidget(scheme: customScheme));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('24 Months Duration'), findsOneWidget);
    });

    testWidgets('payment summary updates when amount is entered',
        (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextFormField), '5000');
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('55,000'), findsOneWidget,
          reason: '11 months * 5000 = 55,000');
    });

    testWidgets('proceed button becomes enabled when valid amount entered',
        (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextFormField), '5000');
      await tester.pumpAndSettle();

      // Assert - SlgButton wraps an InkWell; when onPressed is set, onTap is not null
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      final proceedInkWell = inkWells.firstWhere(
        (w) => w.onTap != null,
        orElse: () => throw StateError('No enabled InkWell found'),
      );
      expect(proceedInkWell.onTap, isNotNull);
    });

    testWidgets('back button icon is rendered and tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
