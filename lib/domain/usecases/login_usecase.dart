// lib/domain/usecases/login_usecase.dart
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repo;
  SendOtpUseCase(this._repo);
  Future<void> call(String phone) => _repo.sendOtp(phone);
}

class VerifyOtpUseCase {
  final AuthRepository _repo;
  VerifyOtpUseCase(this._repo);
  Future<UserEntity> call(String verificationId, String otp) =>
      _repo.verifyOtp(verificationId, otp);
}

class GetCurrentUserUseCase {
  final AuthRepository _repo;
  GetCurrentUserUseCase(this._repo);
  Future<UserEntity?> call() => _repo.getCurrentUser();
}

class SignOutUseCase {
  final AuthRepository _repo;
  SignOutUseCase(this._repo);
  Future<void> call() => _repo.signOut();
}