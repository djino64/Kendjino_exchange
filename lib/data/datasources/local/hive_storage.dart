// lib/data/datasources/local/hive_storage.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

class HiveStorage {
  // ── Transactions cache ─────────────────────────────────────────────────────
  Future<void> cacheTransactions(List<Map<String, dynamic>> txs) async {
    final box = Hive.box(AppConstants.transactionsBox);
    await box.put('cached_transactions', jsonEncode(txs));
    await box.put('cache_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>> getCachedTransactions() {
    final box = Hive.box(AppConstants.transactionsBox);
    final raw = box.get('cached_transactions');
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw as String);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  bool isCacheStale({Duration maxAge = const Duration(minutes: 10)}) {
    final box = Hive.box(AppConstants.transactionsBox);
    final ts = box.get('cache_timestamp') as int?;
    if (ts == null) return true;
    final cached = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cached) > maxAge;
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(key, value);
  }

  T? getSetting<T>(String key) {
    final box = Hive.box(AppConstants.settingsBox);
    return box.get(key) as T?;
  }

  // ── Offline queue ──────────────────────────────────────────────────────────
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    final box = Hive.box(AppConstants.offlineCacheBox);
    final existing = box.get('queue') as List? ?? [];
    existing.add(jsonEncode(action));
    await box.put('queue', existing);
  }

  List<Map<String, dynamic>> getOfflineQueue() {
    final box = Hive.box(AppConstants.offlineCacheBox);
    final raw = box.get('queue') as List? ?? [];
    return raw
        .map((e) => jsonDecode(e as String) as Map<String, dynamic>)
        .toList();
  }

  Future<void> clearOfflineQueue() async {
    final box = Hive.box(AppConstants.offlineCacheBox);
    await box.delete('queue');
  }

  // ── Exchange rate cache ────────────────────────────────────────────────────
  Future<void> cacheExchangeRate(String pair, double rate) async {
    final box = Hive.box(AppConstants.offlineCacheBox);
    await box.put('rate_$pair', rate);
    await box.put('rate_${pair}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  double? getCachedRate(String pair) {
    final box = Hive.box(AppConstants.offlineCacheBox);
    return box.get('rate_$pair') as double?;
  }
}