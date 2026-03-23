import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPinUseCase {
  final AuthRepository repository;

  VerifyPinUseCase(this.repository);

  Future<Either<Failure, bool>> call(String pin) async {
    return await repository.verifyPin(pin);
  }
}
