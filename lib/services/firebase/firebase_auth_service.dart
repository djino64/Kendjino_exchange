import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

//part 'firebase_auth_service.g.dart';
part 'firebase_auth_service.g.dart';

@riverpod
FirebaseAuthService firebaseAuthService(FirebaseAuthServiceRef ref) {
  return FirebaseAuthService(FirebaseAuth.instance);
}

class FirebaseAuthService {
  final FirebaseAuth _auth;
  String? _verificationId;
  int? _resendToken;

  FirebaseAuthService(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Send OTP to phone number (e.g., +50912345678)
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onError,
    void Function(PhoneAuthCredential)? onAutoVerified,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android
          onAutoVerified?.call(credential);
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('OTP verification failed: ${e.code} - ${e.message}');
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('Auto-retrieval timeout for: $verificationId');
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('sendOtp error: $e');
      rethrow;
    }
  }

  /// Verify the OTP entered by the user
  Future<UserCredential?> verifyOtp({
    required String otp,
    String? verificationId,
  }) async {
    final vId = verificationId ?? _verificationId;
    if (vId == null) {
      throw Exception('No verification ID found. Please request OTP first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: vId,
      smsCode: otp,
    );

    return await _signInWithCredential(credential);
  }

  Future<UserCredential?> _signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in with credential failed: ${e.code}');
      rethrow;
    }
  }

  /// Get current ID token (for API requests)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Check if user is new (first time login)
  bool isNewUser(UserCredential credential) {
    return credential.additionalUserInfo?.isNewUser ?? false;
  }
}

// Auth state provider
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}