import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final email = username.contains('@')
          ? username
          : '$username@slggolds.com';
      final user = await remoteDataSource.loginCustomer(email, password);
      return Right(user);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Invalid email') ||
          msg.contains('already exists') ||
          msg.contains('Unauthorized')) {
        return Left(AuthFailure(msg.replaceFirst('Exception: ', '')));
      }
      return Left(AuthFailure(msg.replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
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
    try {
      final email = '$username@slggolds.com';

      final profileData = {
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'aadhaar': aadhaar,
        'dob': dob,
        'gender': gender,
        'father_name': fatherName,
        'birth_place': birthPlace,
        'address': address,
        'nominee_name': nomineeName,
        'nominee_relationship': nomineeRelationship,
        'created_at': DateTime.now().toIso8601String(),
      };

      final user = await remoteDataSource.registerCustomer(
        email: email,
        password: password,
        profileData: profileData,
        pin: pin,
      );

      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      final isValid = await remoteDataSource.verifyPin(pin);
      return Right(isValid);
    } catch (e) {
      return Left(AuthFailure('Invalid PIN'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
