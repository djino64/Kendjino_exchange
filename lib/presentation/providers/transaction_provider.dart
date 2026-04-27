// lib/presentation/providers/transaction_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../injection/dependency_injection.dart';
import 'auth_provider.dart';

// ── Transaction List ───────────────────────────────────────────────────────
class TransactionState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;
  final bool isSending;
  final String? lastTxId;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
    this.lastTxId,
  });

  TransactionState copyWith({
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? error,
    bool? isSending,
    String? lastTxId,
  }) =>
      TransactionState(
        transactions: transactions ?? this.transactions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSending: isSending ?? this.isSending,
        lastTxId: lastTxId ?? this.lastTxId,
      );
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(const TransactionState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final txs = await _ref
          .read(transactionRepositoryProvider)
          .getTransactions(user.uid);
      state = state.copyWith(transactions: txs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les transactions',
      );
    }
  }

  Future<bool> sendMoney({
    required String receiverPhone,
    required double amount,
    required String currency,
    String? note,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    state = state.copyWith(isSending: true, error: null);
    try {
      final tx = await _ref.read(sendMoneyUseCaseProvider).call(
            senderUid: user.uid,
            receiverPhone: receiverPhone,
            amount: amount,
            currency: currency,
            note: note,
          );
      state = state.copyWith(
        isSending: false,
        lastTxId: tx.id,
        transactions: [tx, ...state.transactions],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
  (ref) => TransactionNotifier(ref),
);

// Stream version
final transactionStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(transactionRepositoryProvider).watchTransactions(user.uid);
});