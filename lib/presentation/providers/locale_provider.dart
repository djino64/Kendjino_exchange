// lib/presentation/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../injection/dependency_injection.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;

  LocaleNotifier(this._ref) : super(const Locale('fr')) {
    _load();
  }

  void _load() {
    final code = _ref.read(localStorageProvider).getLocale();
    state = Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await _ref.read(localStorageProvider).setLocale(languageCode);
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

// Crypto provider
final cryptoPricesProvider = FutureProvider.autoDispose((ref) async {
  // Will be overridden by crypto_provider.dart
  return <String, double>{};
});