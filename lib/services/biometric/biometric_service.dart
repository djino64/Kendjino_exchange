import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';

part 'biometric_service.g.dart';

@riverpod
BiometricService biometricService(BiometricServiceRef ref) {
  return BiometricService();
}

@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService();
}

// ─── Biometric Authentication ────────────────────────────────────────────────
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled) {
        return false;
      }
      rethrow;
    }
  }

  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}

// ─── Encrypted Secure Storage ─────────────────────────────────────────────────
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── PIN Management ──
  Future<void> savePin(String pin) async {
    final hashed = _hashPin(pin);
    await _storage.write(key: AppConstants.pinKey, value: hashed);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: AppConstants.pinKey);
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: AppConstants.pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: AppConstants.pinKey);
  }

  // ── Biometric Setting ──
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricKey,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricKey);
    return value == 'true';
  }

  // ── Session Token ──
  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: AppConstants.sessionTokenKey, value: token);
  }

  Future<String?> getSessionToken() async {
    return await _storage.read(key: AppConstants.sessionTokenKey);
  }

  Future<void> clearSessionToken() async {
    await _storage.delete(key: AppConstants.sessionTokenKey);
  }

  // ── Generic Encrypted KV ──
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ── User Data (JSON encrypted) ──
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final json = jsonEncode(data);
    final encrypted = _encrypt(json);
    await _storage.write(key: AppConstants.userDataKey, value: encrypted);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final encrypted = await _storage.read(key: AppConstants.userDataKey);
    if (encrypted == null) return null;
    try {
      final json = _decrypt(encrypted);
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Encryption helpers ──
  String _hashPin(String pin) {
    // Simple but effective hash for PIN storage
    final bytes = utf8.encode(pin + _getSalt());
    final hash = base64Encode(bytes);
    return hash;
  }

  String _getSalt() => 'kendjino_x_2024_salt_haïti';

  String _encrypt(String plainText) {
    try {
      final key = enc.Key.fromUtf8('kendjino_secure_key_32_bytes!!!!!');
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.encrypt(plainText, iv: iv).base64;
    } catch (_) {
      return plainText; // Fallback
    }
  }

  String _decrypt(String cipherText) {
    try {
      final key = enc.Key.fromUtf8('kendjino_secure_key_32_bytes!!!!!');
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(cipherText, iv: iv);
    } catch (_) {
      return cipherText;
    }
  }
}
