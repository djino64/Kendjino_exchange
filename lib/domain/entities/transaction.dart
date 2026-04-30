// ─── Transaction Entity ───────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final double? exchangeRate;
  final String? receiverPhone;
  final String? receiverName;
  final String? senderPhone;
  final String? senderName;
  final String? description;
  final String? note;
  final String? referenceNumber;
  final PaymentMethod paymentMethod;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? fee;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.exchangeRate,
    this.receiverPhone,
    this.receiverName,
    this.senderPhone,
    this.senderName,
    this.description,
    this.note,
    this.referenceNumber,
    required this.paymentMethod,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    this.fee,
  });

  bool get isCredit =>
      type == TransactionType.receive ||
      type == TransactionType.received ||
      type == TransactionType.cryptoSell ||
      type == TransactionType.topUp ||
      type == TransactionType.deposit;

  bool get isDebit =>
      type == TransactionType.send ||
      type == TransactionType.transfer ||
      type == TransactionType.cryptoBuy ||
      type == TransactionType.withdrawal ||
      type == TransactionType.cardPayment;

  @override
  List<Object?> get props =>
      [id, userId, type, status, amount, currency, createdAt, note];
}

enum TransactionType {
  send,
  transfer,
  receive,
  received,
  exchange,
  cryptoBuy,
  cryptoSell,
  topUp,
  deposit,
  withdrawal,
  cardPayment,
}

enum TransactionStatus { pending, processing, completed, failed, cancelled }

enum PaymentMethod {
  internal,
  moncash,
  natcash,
  bankTransfer,
  virtualCard,
  crypto,
}
