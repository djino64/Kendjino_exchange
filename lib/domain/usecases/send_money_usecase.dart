// lib/domain/usecases/send_money_usecase.dart
import '../entities/entities.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';

class SendMoneyUseCase {
  final TransactionRepository _txRepo;
  final WalletRepository _walletRepo;

  SendMoneyUseCase(this._txRepo, this._walletRepo);

  Future<TransactionEntity> call({
    required String senderUid,
    required String receiverPhone,
    required double amount,
    required String currency,
    String? note,
  }) async {
    // Validate
    if (amount <= 0) throw Exception('Invalid amount');
    final tx = TransactionEntity(
      id: '',
      userId: senderUid,
      type: TransactionType.send,
      status: TransactionStatus.pending,
      amount: amount,
      currency: currency,
      receiverPhone: receiverPhone,
      description: note,
      paymentMethod: PaymentMethod.wallet,
      createdAt: DateTime.now(),
      
    );

    // Create transaction record
    // final tx = TransactionEntity(
    //   id: '',
    //   senderUid: senderUid,
    //   receiverPhone: receiverPhone,
    //   amount: amount,
    //   currency: currency,
    //   type: TransactionType.transfer,
    //   status: TransactionStatus.pending,
    //   createdAt: DateTime.now(),
    //   note: note,
    // );

    return _txRepo.createTransaction(tx);
  }
}