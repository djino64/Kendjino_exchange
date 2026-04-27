// lib/services/storage/local_storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  // ── Settings ───────────────────────────────────────────────────────────────
  Box get _settings => Hive.box(AppConstants.settingsBox);

  Future<void> setThemeMode(String mode) async =>
      _settings.put('theme_mode', mode);
  String getThemeMode() => _settings.get('theme_mode', defaultValue: 'system');

  Future<void> setLocale(String code) async =>
      _settings.put('locale', code);
  String getLocale() => _settings.get('locale', defaultValue: 'fr');

  Future<void> setOnboardingDone(bool done) async =>
      _settings.put('onboarding_done', done);
  bool isOnboardingDone() =>
      _settings.get('onboarding_done', defaultValue: false);

  Future<void> setNotificationsEnabled(bool enabled) async =>
      _settings.put('notifications_enabled', enabled);
  bool areNotificationsEnabled() =>
      _settings.get('notifications_enabled', defaultValue: true);

  Future<void> setLastUserId(String uid) async =>
      _settings.put('last_user_id', uid);
  String? getLastUserId() => _settings.get('last_user_id');

  // ── Generic ────────────────────────────────────────────────────────────────
  Future<void> put(String key, dynamic value) async =>
      _settings.put(key, value);
  T get<T>(String key, {T? defaultValue}) =>
      _settings.get(key, defaultValue: defaultValue);
  Future<void> delete(String key) async => _settings.delete(key);
  Future<void> clear() async => _settings.clear();
}