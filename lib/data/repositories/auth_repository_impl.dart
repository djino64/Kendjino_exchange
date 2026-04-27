// lib/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firestore_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirestoreSource _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    required FirestoreSource firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore;

  String? _verificationId;

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 120),
    );
  }

  @override
  Future<UserEntity> verifyOtp(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final result = await _auth.signInWithCredential(credential);
    final firebaseUser = result.user!;

    // Try to get existing user or create new one
    UserModel? existing = await _firestore.getUser(firebaseUser.uid);
    if (existing == null) {
      final newUser = UserModel(
        uid: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        createdAt: DateTime.now(),
        isVerified: true,
      );
      await _firestore.saveUser(newUser);
      return newUser;
    }
    return existing;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _firestore.getUser(firebaseUser.uid);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _firestore.saveUser(model);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _firestore.getUser(firebaseUser.uid);
    });
  }

  String? get currentVerificationId => _verificationId;
}