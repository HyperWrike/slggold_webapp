import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/verify_pin_usecase.dart';

// 1. Core Supabase Instance
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// 2. Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseProvider));
});

// 3. Repositories
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// 4. Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  return VerifyPinUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// 5. Auth State Notifier
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final VerifyPinUseCase _verifyPin;

  AuthNotifier(
    this._login,
    this._register,
    this._logout,
    this._getCurrentUser,
    this._verifyPin,
  ) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getCurrentUser();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _login(username, password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String fullName,
    required String username,
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
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _register(
      fullName: fullName,
      username: username,
      password: password,
      phone: phone,
      aadhaar: aadhaar,
      dob: dob,
      gender: gender,
      fatherName: fatherName,
      birthPlace: birthPlace,
      address: address,
      nomineeName: nomineeName,
      nomineeRelationship: nomineeRelationship,
      pin: pin,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _logout();
    state = const AuthState();
  }

  Future<bool> verifyPin(String pin) async {
    final result = await _verifyPin(pin);
    return result.fold((l) => false, (r) => r);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(registerUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
    ref.watch(getCurrentUserUseCaseProvider),
    ref.watch(verifyPinUseCaseProvider),
  );
});
