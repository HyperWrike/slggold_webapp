import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String username, String password);
  
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
  });

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> verifyPin(String pin);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
