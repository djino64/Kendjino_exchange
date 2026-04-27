// lib/data/datasources/remote/firestore_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';

class FirestoreSource {
  final FirebaseFirestore _db;
  FirestoreSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Users ──────────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> saveUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  // ── Wallets ────────────────────────────────────────────────────────────────
  Future<WalletModel?> getWallet(String userId) async {
    final query = await _db
        .collection(AppConstants.walletsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return WalletModel.fromFirestore(doc.data(), doc.id);
  }

  Future<WalletModel> createWallet(WalletModel wallet) async {
    final ref = _db.collection(AppConstants.walletsCollection).doc();
    final withId = WalletModel(
      id: ref.id,
      userId: wallet.userId,
      htgBalance: wallet.htgBalance,
      usdBalance: wallet.usdBalance,
      walletNumber: wallet.walletNumber,
      createdAt: wallet.createdAt,
      usdtBalance: wallet.usdtBalance,
      btcBalance: wallet.btcBalance,
    );
    await ref.set(withId.toFirestore());
    return withId;
  }

  Future<void> updateWalletBalance(
    String walletId,
    String currency,
    double amount,
  ) async {
    final field = _currencyToField(currency);
    await _db
        .collection(AppConstants.walletsCollection)
        .doc(walletId)
        .update({field: FieldValue.increment(amount)});
  }

  Stream<WalletModel?> watchWallet(String userId) {
    return _db
        .collection(AppConstants.walletsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return WalletModel.fromFirestore(doc.data(), doc.id);
    });
  }

  // ── Transactions ───────────────────────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    int limit = 20,
    DocumentSnapshot? cursor,
  }) async {
    Query query = _db
        .collection(AppConstants.transactionsCollection)
        .where('senderUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (cursor != null) query = query.startAfterDocument(cursor);

    final snap = await query.get();
    return snap.docs.map((d) {
      return TransactionModel.fromFirestore(
          d.data() as Map<String, dynamic>, d.id);
    }).toList();
  }

  Future<TransactionModel> createTransaction(TransactionModel tx) async {
    final ref = _db.collection(AppConstants.transactionsCollection).doc();
    final withId = TransactionModel(
      id: ref.id,
      senderUid: tx.senderUid,
      receiverPhone: tx.receiverPhone,
      amount: tx.amount,
      currency: tx.currency,
      type: tx.type,
      status: tx.status,
      createdAt: tx.createdAt,
      fee: tx.fee,
      note: tx.note,
      referenceNumber: tx.referenceNumber,
      receiverName: tx.receiverName,
      senderPhone: tx.senderPhone,
    );
    await ref.set(withId.toFirestore());
    return withId;
  }

  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _db
        .collection(AppConstants.transactionsCollection)
        .where('senderUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TransactionModel.fromFirestore(
                d.data(), d.id))
            .toList());
  }

  String _currencyToField(String currency) {
    switch (currency) {
      case 'HTG': return 'htgBalance';
      case 'USD': return 'usdBalance';
      case 'USDT': return 'usdtBalance';
      case 'BTC': return 'btcBalance';
      default: return 'htgBalance';
    }
  }
}