import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:slg_golds/core/errors/failures.dart';
import 'package:slg_golds/domain/entities/user_entity.dart';
import 'package:slg_golds/domain/repositories/auth_repository.dart';
import 'package:slg_golds/domain/usecases/auth/login_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/register_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/logout_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:slg_golds/domain/usecases/auth/verify_pin_usecase.dart';
import 'package:slg_golds/presentation/providers/auth_provider.dart';

const _testUser = UserEntity(
  id: 'user_123',
  fullName: 'Test User',
  username: 'testuser',
  phone: '9876543210',
  role: 'customer',
  hasPinSetup: true,
);

class _MockAuthRepository implements AuthRepository {
  Either<Failure, UserEntity>? loginResult;
  Either<Failure, UserEntity>? registerResult;
  Either<Failure, void>? logoutResult;
  Either<Failure, bool>? verifyPinResult;
  Either<Failure, UserEntity?>? getCurrentUserResult;

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async => loginResult!;

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
  }) async => registerResult!;

  @override
  Future<Either<Failure, void>> logout() async => logoutResult!;

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async =>
      verifyPinResult!;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async =>
      getCurrentUserResult!;
}

void main() {
  late _MockAuthRepository mockRepo;
  late AuthNotifier notifier;

  setUp(() {
    mockRepo = _MockAuthRepository();
  });

  AuthNotifier createNotifier() {
    return AuthNotifier(
      LoginUseCase(mockRepo),
      RegisterUseCase(mockRepo),
      LogoutUseCase(mockRepo),
      GetCurrentUserUseCase(mockRepo),
      VerifyPinUseCase(mockRepo),
    );
  }

  group('AuthNotifier', () {
    test('initial state has no user and is not loading', () {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure('Not logged in'));

      // Act
      notifier = createNotifier();

      // Assert
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, isNull);
    });

    test('checkAuthStatus sets user when session exists', () async {
      // Arrange
      mockRepo.getCurrentUserResult = Right(_testUser);

      // Act
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.user, equals(_testUser));
      expect(notifier.state.isLoading, isFalse);
    });

    test('checkAuthStatus sets error when no session', () async {
      // Arrange
      mockRepo.getCurrentUserResult =
          const Left(AuthFailure('No session'));

      // Act
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, equals('No session'));
    });

    test('login returns true on success and updates user', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.loginResult = Right(_testUser);
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.login('testuser', 'password123');

      // Assert
      expect(result, isTrue);
      expect(notifier.state.user, equals(_testUser));
      expect(notifier.state.isLoading, isFalse);
    });

    test('login returns false on failure and sets error', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.loginResult =
          const Left(AuthFailure('Invalid credentials'));
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.login('testuser', 'wrong');

      // Assert
      expect(result, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, equals('Invalid credentials'));
    });

    test('logout clears user state', () async {
      // Arrange
      mockRepo.getCurrentUserResult = Right(_testUser);
      mockRepo.logoutResult = const Right(null);
      notifier = createNotifier();
      await Future.delayed(Duration.zero);
      expect(notifier.state.user, isNotNull);

      // Act
      await notifier.logout();

      // Assert
      expect(notifier.state.user, isNull);
      expect(notifier.state.error, isNull);
    });

    test('verifyPin returns true on success', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.verifyPinResult = const Right(true);
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.verifyPin('1234');

      // Assert
      expect(result, isTrue);
    });

    test('verifyPin returns false on failure', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.verifyPinResult =
          const Left(AuthFailure('Wrong PIN'));
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.verifyPin('9999');

      // Assert
      expect(result, isFalse);
    });

    test('register succeeds and updates user', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.registerResult = Right(_testUser);
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.register(
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        password: 'pass123',
        phone: '9876543210',
        aadhaar: '123456789012',
        dob: '01/01/1990',
        gender: 'Male',
        fatherName: 'Father Name',
        birthPlace: 'City',
        address: 'Address',
        nomineeName: 'Nominee',
        nomineeRelationship: 'Father',
        pin: '1234',
      );

      // Assert
      expect(result, isTrue);
      expect(notifier.state.user, equals(_testUser));
    });

    test('register fails and sets error', () async {
      // Arrange
      mockRepo.getCurrentUserResult = const Left(AuthFailure());
      mockRepo.registerResult =
          const Left(AuthFailure('Username taken'));
      notifier = createNotifier();
      await Future.delayed(Duration.zero);

      // Act
      final result = await notifier.register(
        fullName: 'Test User',
        username: 'taken_user',
        email: 'test@example.com',
        password: 'pass123',
        phone: '9876543210',
        aadhaar: '123456789012',
        dob: '01/01/1990',
        gender: 'Male',
        fatherName: 'Father Name',
        birthPlace: 'City',
        address: 'Address',
        nomineeName: 'Nominee',
        nomineeRelationship: 'Father',
        pin: '1234',
      );

      // Assert
      expect(result, isFalse);
      expect(notifier.state.error, equals('Username taken'));
    });
  });

  group('AuthState', () {
    test('copyWith preserves existing values', () {
      // Arrange
      const state = AuthState(
        user: _testUser,
        isLoading: false,
        error: 'old error',
      );

      // Act
      final updated = state.copyWith(isLoading: true);

      // Assert
      expect(updated.user, equals(_testUser));
      expect(updated.isLoading, isTrue);
      expect(updated.error, equals('old error'));
    });

    test('copyWith clearError removes error', () {
      // Arrange
      const state = AuthState(error: 'some error');

      // Act
      final updated = state.copyWith(clearError: true);

      // Assert
      expect(updated.error, isNull);
    });

    test('copyWith overrides user', () {
      // Arrange
      const state = AuthState();

      // Act
      final updated = state.copyWith(user: _testUser);

      // Assert
      expect(updated.user, equals(_testUser));
    });

    test('default AuthState has no user, not loading, no error', () {
      // Arrange & Act
      const state = AuthState();

      // Assert
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });
  });
}
