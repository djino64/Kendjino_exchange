// lib/data/models/transaction_model.dart
import '../../domain/entities/entities.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.senderUid,
    required super.receiverPhone,
    required super.amount,
    required super.currency,
    required super.type,
    required super.status,
    required super.createdAt,
    super.fee,
    super.note,
    super.referenceNumber,
    super.completedAt,
    super.receiverName,
    super.senderPhone,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      senderUid: data['senderUid'] ?? '',
      receiverPhone: data['receiverPhone'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'HTG',
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.transfer,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
      fee: (data['fee'] as num?)?.toDouble(),
      note: data['note'],
      referenceNumber: data['referenceNumber'],
      receiverName: data['receiverName'],
      senderPhone: data['senderPhone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderUid': senderUid,
      'receiverPhone': receiverPhone,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt,
      'fee': fee,
      'note': note,
      'referenceNumber': referenceNumber,
      'receiverName': receiverName,
      'senderPhone': senderPhone,
    };
  }
}