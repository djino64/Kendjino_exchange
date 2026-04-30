import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

part 'crypto_service.g.dart';

@riverpod
CryptoService cryptoService(CryptoServiceRef ref) {
  return CryptoService();
}

class CryptoService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.cryptoPriceBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _uuid = const Uuid();
  final _rng = Random();

  // ── Price Fetching ───────────────────────────────────────────────────────
  Future<List<CryptoAssetEntity>> getMarketPrices({
    List<String> ids = const ['bitcoin', 'tether'],
    String vsCurrency = 'usd',
  }) async {
    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': vsCurrency,
          'ids': ids.join(','),
          'order': 'market_cap_desc',
          'per_page': 10,
          'page': 1,
          'sparkline': false,
          'price_change_percentage': '24h',
        },
      );

      final List<dynamic> coins = response.data;
      return coins.map((coin) => _mapCoinGeckoAsset(coin)).toList();
    } on DioException catch (e) {
      debugPrint('CoinGecko error: ${e.message}');
      // Return mock data if API fails
      return _getMockPrices();
    }
  }

  Future<Map<String, double>> getSimplePrices({
    List<String> ids = const ['bitcoin', 'tether'],
    String vsCurrency = 'usd',
  }) async {
    try {
      final response = await _dio.get(
        '/simple/price',
        queryParameters: {
          'ids': ids.join(','),
          'vs_currencies': vsCurrency,
          'include_24hr_change': 'true',
        },
      );

      final Map<String, dynamic> data = response.data;
      return {
        'BTC': (data['bitcoin']?[vsCurrency] as num?)?.toDouble() ??
            AppConstants.defaultBtcToUsd,
        'USDT': (data['tether']?[vsCurrency] as num?)?.toDouble() ?? 1.0,
      };
    } on DioException {
      return {
        'BTC': AppConstants.defaultBtcToUsd,
        'USDT': 1.0,
      };
    }
  }

  Future<List<double>> getPriceHistory({
    required String coinId,
    int days = 7,
    String vsCurrency = 'usd',
  }) async {
    try {
      final response = await _dio.get(
        '/coins/$coinId/market_chart',
        queryParameters: {
          'vs_currency': vsCurrency,
          'days': days,
        },
      );

      final List<dynamic> prices = response.data['prices'];
      return prices
          .map((p) => (p[1] as num).toDouble())
          .toList();
    } on DioException {
      return _generateMockHistory(days);
    }
  }

  // ── Crypto Transactions (Mock) ───────────────────────────────────────────
  Future<CryptoTransactionResult> buyCrypto({
    required String userId,
    required String symbol,
    required double amountUsd,
    required double currentPriceUsd,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final cryptoAmount = amountUsd / currentPriceUsd;
    final fee = amountUsd * 0.015; // 1.5% fee
    final totalUsd = amountUsd + fee;

    return CryptoTransactionResult(
      success: true,
      transactionId: 'CRYPTO_BUY_${_uuid.v4().substring(0, 8).toUpperCase()}',
      symbol: symbol,
      cryptoAmount: cryptoAmount,
      usdAmount: amountUsd,
      fee: fee,
      totalUsd: totalUsd,
      pricePerUnit: currentPriceUsd,
      type: CryptoTxType.buy,
      timestamp: DateTime.now(),
      txHash: _generateMockTxHash(),
    );
  }

  Future<CryptoTransactionResult> sellCrypto({
    required String userId,
    required String symbol,
    required double cryptoAmount,
    required double currentPriceUsd,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final usdAmount = cryptoAmount * currentPriceUsd;
    final fee = usdAmount * 0.015;
    final netUsd = usdAmount - fee;

    return CryptoTransactionResult(
      success: true,
      transactionId: 'CRYPTO_SELL_${_uuid.v4().substring(0, 8).toUpperCase()}',
      symbol: symbol,
      cryptoAmount: cryptoAmount,
      usdAmount: netUsd,
      fee: fee,
      totalUsd: usdAmount,
      pricePerUnit: currentPriceUsd,
      type: CryptoTxType.sell,
      timestamp: DateTime.now(),
      txHash: _generateMockTxHash(),
    );
  }

  Future<CryptoTransactionResult> sendCrypto({
    required String fromUserId,
    required String toAddress,
    required String symbol,
    required double amount,
  }) async {
    await Future.delayed(const Duration(seconds: 3));

    final fee = symbol == 'BTC' ? 0.00005 : 1.0; // Network fee

    return CryptoTransactionResult(
      success: true,
      transactionId: 'CRYPTO_SEND_${_uuid.v4().substring(0, 8).toUpperCase()}',
      symbol: symbol,
      cryptoAmount: amount,
      usdAmount: 0,
      fee: fee,
      totalUsd: 0,
      pricePerUnit: 0,
      type: CryptoTxType.send,
      timestamp: DateTime.now(),
      txHash: _generateMockTxHash(),
      toAddress: toAddress,
    );
  }

  // ── Wallet Address Generation (Mock) ─────────────────────────────────────
  String generateWalletAddress(String symbol) {
    if (symbol == 'BTC') {
      return 'bc1q${_generateRandomHex(38)}';
    }
    if (symbol == 'USDT') {
      return '0x${_generateRandomHex(40)}'; // ERC-20 address
    }
    return _generateRandomHex(42);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  CryptoAssetEntity _mapCoinGeckoAsset(Map<String, dynamic> coin) {
    return CryptoAssetEntity(
      symbol: (coin['symbol'] as String).toUpperCase(),
      name: coin['name'],
      priceUsd: (coin['current_price'] as num).toDouble(),
      change24h: (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      iconUrl: coin['image'] ?? '',
    );
  }

  List<CryptoAssetEntity> _getMockPrices() {
    return [
      const CryptoAssetEntity(
        symbol: 'BTC',
        name: 'Bitcoin',
        priceUsd: 65420.50,
        change24h: 2.35,
        iconUrl: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
      ),
      const CryptoAssetEntity(
        symbol: 'USDT',
        name: 'Tether',
        priceUsd: 1.0001,
        change24h: 0.01,
        iconUrl: 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
      ),
    ];
  }

  List<double> _generateMockHistory(int days) {
    double price = 65000;
    return List.generate(days * 24, (i) {
      price += (_rng.nextDouble() - 0.5) * 500;
      price = price.clamp(50000, 80000);
      return price;
    });
  }

  String _generateMockTxHash() {
    return '0x${_generateRandomHex(64)}';
  }

  String _generateRandomHex(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[_rng.nextInt(chars.length)]).join();
  }
}

// ─── Result Models ─────────────────────────────────────────────────────────
class CryptoTransactionResult {
  final bool success;
  final String transactionId;
  final String symbol;
  final double cryptoAmount;
  final double usdAmount;
  final double fee;
  final double totalUsd;
  final double pricePerUnit;
  final CryptoTxType type;
  final DateTime timestamp;
  final String txHash;
  final String? toAddress;
  final String? errorMessage;

  const CryptoTransactionResult({
    required this.success,
    required this.transactionId,
    required this.symbol,
    required this.cryptoAmount,
    required this.usdAmount,
    required this.fee,
    required this.totalUsd,
    required this.pricePerUnit,
    required this.type,
    required this.timestamp,
    required this.txHash,
    this.toAddress,
    this.errorMessage,
  });
}

enum CryptoTxType { buy, sell, send, receive }