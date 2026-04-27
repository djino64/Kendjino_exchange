// lib/services/firebase/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).set(data);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  // ── Wallet ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getWallet(String userId) async {
    final snap = await _db
        .collection(AppConstants.walletsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return {'id': snap.docs.first.id, ...snap.docs.first.data()};
  }

  Future<String> createWallet(Map<String, dynamic> data) async {
    final ref = await _db.collection(AppConstants.walletsCollection).add(data);
    return ref.id;
  }

  Future<void> updateWalletBalance(
      String walletId, String field, double delta) async {
    await _db
        .collection(AppConstants.walletsCollection)
        .doc(walletId)
        .update({field: FieldValue.increment(delta)});
  }

  Stream<Map<String, dynamic>?> watchWallet(String userId) {
    return _db
        .collection(AppConstants.walletsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : {'id': s.docs.first.id, ...s.docs.first.data()});
  }

  // ── Transactions ───────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTransactions(
    String userId, {
    int limit = 20,
  }) async {
    final snap = await _db
        .collection(AppConstants.transactionsCollection)
        .where('senderUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList();
  }

  Future<String> addTransaction(Map<String, dynamic> data) async {
    final ref =
        await _db.collection(AppConstants.transactionsCollection).add(data);
    return ref.id;
  }

  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('senderUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── Exchange rates ─────────────────────────────────────────────────────────
  Future<double?> getExchangeRate(String pair) async {
    final doc = await _db
        .collection(AppConstants.exchangeRatesCollection)
        .doc(pair)
        .get();
    if (!doc.exists) return null;
    return (doc.data()?['rate'] as num?)?.toDouble();
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  Future<void> saveNotification(
      String userId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.notificationsCollection)
        .add({'userId': userId, 'createdAt': FieldValue.serverTimestamp(), ...data});
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _db
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}