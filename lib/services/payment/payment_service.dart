import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

part 'payment_service.g.dart';

@riverpod
PaymentService paymentService(PaymentServiceRef ref) {
  return PaymentService();
}


// ─── Payment Service (MonCash + NatCash + Internal) ──────────────────────────
class PaymentService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static const bool _useMock = true; // Toggle for real API
  final _uuid = const Uuid();
  final _rng = Random();

  // ── MonCash Integration ──────────────────────────────────────────────────
  Future<PaymentResult> initiateMoncashPayment({
    required double amount,
    required String orderId,
    required String description,
  }) async {
    if (_useMock) {
      return await _mockMoncashPayment(amount, orderId);
    }

    try {
      // Real MonCash API call would go here
      // MonCash Business API: https://sandbox.moncashbutton.digicelhaiti.com
      final response = await _dio.post(
        '${AppConstants.moncashMockBase}/payment/initialize',
        data: {
          'amount': amount,
          'orderId': orderId,
          'description': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getMoncashToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return PaymentResult.fromMoncash(response.data);
    } on DioException catch (e) {
      debugPrint('MonCash error: ${e.message}');
      return PaymentResult.failed(
        e.message ?? 'MonCash payment failed',
        PaymentProvider.moncash,
      );
    }
  }

  Future<PaymentResult> verifyMoncashPayment(String orderId) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return PaymentResult(
        success: true,
        transactionId: 'MC_${_uuid.v4().substring(0, 8).toUpperCase()}',
        amount: 0,
        currency: AppConstants.htgCurrency,
        provider: PaymentProvider.moncash,
        status: PaymentStatus.completed,
        message: 'Payment verified',
        timestamp: DateTime.now(),
      );
    }

    final response = await _dio.post(
      '${AppConstants.moncashMockBase}/payment/getPayment',
      data: {'orderId': orderId},
    );
    return PaymentResult.fromMoncash(response.data);
  }

  // ── NatCash Integration ──────────────────────────────────────────────────
  Future<PaymentResult> initiateNatcashTransfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
    String? description,
  }) async {
    if (_useMock) {
      return await _mockNatcashTransfer(senderPhone, receiverPhone, amount);
    }

    try {
      final response = await _dio.post(
        '${AppConstants.natcashMockBase}/transfer',
        data: {
          'sender': senderPhone,
          'receiver': receiverPhone,
          'amount': amount,
          'currency': 'HTG',
          'description': description ?? 'Kendjino Transfer',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_getNatcashToken()}'},
        ),
      );
      return PaymentResult.fromNatcash(response.data);
    } on DioException catch (e) {
      return PaymentResult.failed(
        e.message ?? 'NatCash transfer failed',
        PaymentProvider.natcash,
      );
    }
  }

  // ── Internal P2P Transfer ────────────────────────────────────────────────
  Future<TransferResult> internalTransfer({
    required String senderUid,
    required String receiverPhone,
    required double amount,
    required String currency,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final txId = 'KX_${_uuid.v4().substring(0, 10).toUpperCase()}';
    final fee = _calculateFee(amount, currency);
    final totalDeducted = amount + fee;

    return TransferResult(
      success: true,
      transactionId: txId,
      amount: amount,
      fee: fee,
      totalDeducted: totalDeducted,
      currency: currency,
      receiverPhone: receiverPhone,
      timestamp: DateTime.now(),
      referenceNumber: 'REF${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ── Mock Implementations ────────────────────────────────────────────────
  Future<PaymentResult> _mockMoncashPayment(double amount, String orderId) async {
    await Future.delayed(const Duration(seconds: 2));
    final success = _rng.nextDouble() > 0.1; // 90% success rate in mock

    return PaymentResult(
      success: success,
      transactionId: success
          ? 'MC_${_uuid.v4().substring(0, 8).toUpperCase()}'
          : null,
      amount: amount,
      currency: AppConstants.htgCurrency,
      provider: PaymentProvider.moncash,
      status: success ? PaymentStatus.completed : PaymentStatus.failed,
      message: success ? 'Paiement MonCash réussi' : 'Paiement échoué',
      timestamp: DateTime.now(),
      deepLink: success
          ? 'moncash://payment?token=mock_$orderId'
          : null,
    );
  }

  Future<PaymentResult> _mockNatcashTransfer(
    String sender,
    String receiver,
    double amount,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return PaymentResult(
      success: true,
      transactionId: 'NC_${_uuid.v4().substring(0, 8).toUpperCase()}',
      amount: amount,
      currency: AppConstants.htgCurrency,
      provider: PaymentProvider.natcash,
      status: PaymentStatus.completed,
      message: 'Transfert NatCash réussi',
      timestamp: DateTime.now(),
    );
  }

  // ── Utilities ────────────────────────────────────────────────────────────
  double _calculateFee(double amount, String currency) {
    if (currency == AppConstants.htgCurrency) {
      if (amount <= 500) return 5.0;
      if (amount <= 5000) return amount * 0.01;
      return amount * 0.008; // 0.8% for large transfers
    }
    if (currency == AppConstants.usdCurrency) {
      return amount * 0.015; // 1.5% for USD
    }
    return amount * 0.01;
  }

  String _getMoncashToken() => 'mock_moncash_token_${DateTime.now().millisecondsSinceEpoch}';
  String _getNatcashToken() => 'mock_natcash_token_${DateTime.now().millisecondsSinceEpoch}';

  // ── QR Code payment data ─────────────────────────────────────────────────
  String generatePaymentQrData({
    required String userId,
    required String walletNumber,
    String? amount,
    String currency = 'HTG',
  }) {
    final params = {
      'app': 'Kendjino',
      'uid': userId,
      'wallet': walletNumber,
      'amount': amount,
      'currency': currency,
    };
    return Uri(queryParameters: params).query;
  }
}

// ─── Result Models ────────────────────────────────────────────────────────────
class PaymentResult {
  final bool success;
  final String? transactionId;
  final double amount;
  final String currency;
  final PaymentProvider provider;
  final PaymentStatus status;
  final String message;
  final DateTime timestamp;
  final String? deepLink;
  final Map<String, dynamic>? rawData;

  const PaymentResult({
    required this.success,
    this.transactionId,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.status,
    required this.message,
    required this.timestamp,
    this.deepLink,
    this.rawData,
  });

  factory PaymentResult.failed(String message, PaymentProvider provider) {
    return PaymentResult(
      success: false,
      amount: 0,
      currency: 'HTG',
      provider: provider,
      status: PaymentStatus.failed,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  factory PaymentResult.fromMoncash(Map<String, dynamic> data) {
    return PaymentResult(
      success: data['status'] == 'SUCCESS',
      transactionId: data['transaction_id'],
      amount: (data['amount'] as num).toDouble(),
      currency: 'HTG',
      provider: PaymentProvider.moncash,
      status: data['status'] == 'SUCCESS'
          ? PaymentStatus.completed
          : PaymentStatus.failed,
      message: data['message'] ?? '',
      timestamp: DateTime.now(),
      rawData: data,
    );
  }

  factory PaymentResult.fromNatcash(Map<String, dynamic> data) {
    return PaymentResult(
      success: data['code'] == '0',
      transactionId: data['ref'],
      amount: (data['amount'] as num).toDouble(),
      currency: 'HTG',
      provider: PaymentProvider.natcash,
      status: data['code'] == '0'
          ? PaymentStatus.completed
          : PaymentStatus.failed,
      message: data['message'] ?? '',
      timestamp: DateTime.now(),
      rawData: data,
    );
  }
}

class TransferResult {
  final bool success;
  final String transactionId;
  final double amount;
  final double fee;
  final double totalDeducted;
  final String currency;
  final String receiverPhone;
  final DateTime timestamp;
  final String referenceNumber;
  final String? errorMessage;

  const TransferResult({
    required this.success,
    required this.transactionId,
    required this.amount,
    required this.fee,
    required this.totalDeducted,
    required this.currency,
    required this.receiverPhone,
    required this.timestamp,
    required this.referenceNumber,
    this.errorMessage,
  });
}

enum PaymentProvider { moncash, natcash, internal, stripe }
enum PaymentStatus { pending, processing, completed, failed, cancelled }