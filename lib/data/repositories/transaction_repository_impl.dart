// lib/data/repositories/transaction_repository_impl.dart
import '../../domain/entities/entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/firestore_source.dart';
import '../datasources/local/hive_storage.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirestoreSource _firestore;
  final HiveStorage _local;

  TransactionRepositoryImpl({
    required FirestoreSource firestore,
    required HiveStorage local,
  })  : _firestore = firestore,
        _local = local;

  @override
  Future<List<TransactionEntity>> getTransactions(
    String userId, {
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final txs = await _firestore.getTransactions(userId, limit: limit);
      // Cache for offline
      await _local.cacheTransactions(
        txs.map((t) => _txToMap(t)).toList(),
      );
      return txs;
    } catch (_) {
      // Offline fallback
      return _local.getCachedTransactions().map((m) {
        return TransactionModel.fromFirestore(m, m['id'] ?? '');
      }).toList();
    }
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionEntity tx) async {
    final model = TransactionModel(
      id: tx.id,
      userId: tx.userId,
      senderName: tx.senderName ?? '',
      senderPhone: tx.senderPhone ?? '',
      receiverPhone: tx.receiverPhone ?? '',
      amount: tx.amount,
      currency: tx.currency,
      type: tx.type,
      status: tx.status,
      createdAt: tx.createdAt,
      paymentMethod: tx.paymentMethod,
      fee: tx.fee,
      note: tx.description,
      referenceNumber: tx.referenceNumber,
      receiverName: tx.receiverName,
      completedAt: tx.completedAt,
    );
    return _firestore.createTransaction(model);
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions(String userId) {
    return _firestore.watchTransactions(userId);
  }

  @override
  Future<TransactionEntity?> getTransaction(String txId) async {
    // Simplified — would query Firestore by doc ID
    return null;
  }

  Map<String, dynamic> _txToMap(TransactionEntity tx) => {
        'id': tx.id,
        'userId': tx.userId,
        'senderUid': tx.userId,
        'senderName': tx.senderName,
        'senderPhone': tx.senderPhone,
        'receiverPhone': tx.receiverPhone,
        'amount': tx.amount,
        'currency': tx.currency,
        'type': tx.type.name,
        'status': tx.status.name,
        'createdAt': tx.createdAt.millisecondsSinceEpoch,
        'paymentMethod': tx.paymentMethod.name,
        'fee': tx.fee,
        'note': tx.description,
        'referenceNumber': tx.referenceNumber,
        'receiverName': tx.receiverName,
      };
}
