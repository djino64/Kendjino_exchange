// lib/services/payment/natcash_mock_service.dart
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'payment_service.dart';

class NatcashMockService {
  final _uuid = const Uuid();
  final _rng = Random();

  Future<PaymentResult> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    await Future.delayed(Duration(milliseconds: 800 + _rng.nextInt(700)));

    final success = _rng.nextDouble() > 0.05;

    return PaymentResult(
      success: success,
      transactionId: success
          ? 'NC_${_uuid.v4().substring(0, 8).toUpperCase()}'
          : null,
      amount: amount,
      currency: 'HTG',
      provider: PaymentProvider.natcash,
      status: success ? PaymentStatus.completed : PaymentStatus.failed,
      message: success
          ? 'Transfert NatCash réussi'
          : 'Solde insuffisant ou erreur réseau',
      timestamp: DateTime.now(),
    );
  }

  Future<PaymentResult> checkBalance(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final balance = 5000 + _rng.nextDouble() * 45000;

    return PaymentResult(
      success: true,
      transactionId: null,
      amount: balance,
      currency: 'HTG',
      provider: PaymentProvider.natcash,
      status: PaymentStatus.completed,
      message: 'Solde disponible: ${balance.toStringAsFixed(2)} HTG',
      timestamp: DateTime.now(),
    );
  }
}