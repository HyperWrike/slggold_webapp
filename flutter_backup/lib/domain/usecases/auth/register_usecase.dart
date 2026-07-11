import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
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
  }) async {
    return await repository.register(
      fullName: fullName,
      username: username,
      email: email,
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
  }
}
