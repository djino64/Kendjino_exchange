// lib/domain/repositories/transaction_repository.dart
import '../entities/entities.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions(String userId, {int limit = 20, String? cursor});
  Future<TransactionEntity> createTransaction(TransactionEntity tx);
  Stream<List<TransactionEntity>> watchTransactions(String userId);
  Future<TransactionEntity?> getTransaction(String txId);
}