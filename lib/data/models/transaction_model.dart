// lib/data/models/transaction_model.dart
import '../../domain/entities/entities.dart';

class TransactionModel extends TransactionEntity {
  final String? note;

  const TransactionModel({
    required super.id,
    required super.userId,
    required String super.senderName,
    required String super.senderPhone,
    required String super.receiverPhone,
    required super.amount,
    required super.currency,
    required super.type,
    required super.status,
    required super.createdAt,
    required super.paymentMethod,
    super.fee,
    this.note,
    super.referenceNumber,
    super.completedAt,
    super.receiverName,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? data['senderUid'] ?? '',
      receiverPhone: data['receiverPhone'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'HTG',
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.values.first,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == data['paymentMethod'],
        orElse: () => PaymentMethod.values.first,
      ),
      fee: (data['fee'] as num?)?.toDouble(),
      note: data['note'],
      referenceNumber: data['referenceNumber'],
      receiverName: data['receiverName'],
      senderPhone: data['senderPhone'] ?? '',
      senderName: data['senderName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'senderUid': userId,
      'receiverPhone': receiverPhone,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod.name,
      'fee': fee,
      'note': note,
      'referenceNumber': referenceNumber,
      'receiverName': receiverName,
      'senderPhone': senderPhone,
      'senderName': senderName,
    };
  }
}
