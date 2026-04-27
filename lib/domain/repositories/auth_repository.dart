// lib/domain/repositories/auth_repository.dart
import '../entities/entities.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<UserEntity> verifyOtp(String verificationId, String otp);
  Future<UserEntity?> getCurrentUser();
  Future<void> signOut();
  Future<void> updateProfile(UserEntity user);
  Stream<UserEntity?> get authStateChanges;
}