// lib/services/payment/moncash_service.dart
// MonCash real integration stub — toggle _useMock = false for production
// Real API: https://sandbox.moncashbutton.digicelhaiti.com/Moncash-middleware
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'payment_service.dart';

class MoncashService {
  static const bool _useMock = true;
  final _uuid = const Uuid();
  final _rng = Random();

  // Real credentials would come from secure storage / env
  static const String _clientId = 'YOUR_MONCASH_CLIENT_ID';
  static const String _clientSecret = 'YOUR_MONCASH_SECRET';

  Future<PaymentResult> initiate({
    required double amount,
    required String orderId,
    String? description,
  }) async {
    if (_useMock) return _mockPayment(amount, orderId);

    // Real MonCash call here:
    // 1. Get access token from /oauth/token
    // 2. POST /v1/CreatePayment with amount + orderId
    // 3. Return deep link to MonCash app
    throw UnimplementedError('Real MonCash not configured');
  }

  Future<PaymentResult> verify(String orderId) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return PaymentResult(
        success: true,
        transactionId: 'MC_${_uuid.v4().substring(0, 8).toUpperCase()}',
        amount: 0,
        currency: 'HTG',
        provider: PaymentProvider.moncash,
        status: PaymentStatus.completed,
        message: 'Paiement vérifié',
        timestamp: DateTime.now(),
      );
    }
    throw UnimplementedError('Real MonCash not configured');
  }

  Future<PaymentResult> _mockPayment(double amount, String orderId) async {
    await Future.delayed(Duration(milliseconds: 1200 + _rng.nextInt(800)));
    final success = _rng.nextDouble() > 0.1;

    return PaymentResult(
      success: success,
      transactionId: success
          ? 'MC_${_uuid.v4().substring(0, 8).toUpperCase()}'
          : null,
      amount: amount,
      currency: 'HTG',
      provider: PaymentProvider.moncash,
      status: success ? PaymentStatus.completed : PaymentStatus.failed,
      message: success ? 'Paiement MonCash réussi ✓' : 'Paiement échoué',
      timestamp: DateTime.now(),
      deepLink: success ? 'moncash://pay?ref=$orderId' : null,
    );
  }
}