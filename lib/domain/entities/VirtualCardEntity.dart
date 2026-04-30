// ─── Virtual Card Entity ──────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

class VirtualCardEntity extends Equatable {
  final String id;
  final String userId;
  final String maskedNumber;
  final String last4;
  final String expiryMonth;
  final String expiryYear;
  final String cardHolderName;
  final String network;
  final double balance;
  final String currency;
  final CardStatus status;
  final bool isVirtual;
  final DateTime issuedAt;

  const VirtualCardEntity({
    required this.id,
    required this.userId,
    required this.maskedNumber,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
    required this.network,
    required this.balance,
    required this.currency,
    this.status = CardStatus.active,
    this.isVirtual = true,
    required this.issuedAt,
  });

  String get displayNumber => '**** **** **** $last4';
  String get displayExpiry => '$expiryMonth/$expiryYear';

  @override
  List<Object?> get props => [id, userId, last4, status];
}

enum CardStatus { active, frozen, expired, cancelled }
