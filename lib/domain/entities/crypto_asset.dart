import 'package:flutter/foundation.dart';

@immutable
class CryptoAssetEntity {
  final String symbol;
  final String name;
  final double priceUsd;
  final double change24h;
  final String iconUrl;
  final double? balance;
  final String? walletAddress;

  const CryptoAssetEntity({
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    required this.iconUrl,
    this.balance,
    this.walletAddress,
  });

  bool get isPositive => change24h >= 0;

  double get balanceUsd => (balance ?? 0) * priceUsd;

  CryptoAssetEntity copyWith({
    double? balance,
    double? priceUsd,
    double? change24h,
    String? walletAddress,
  }) {
    return CryptoAssetEntity(
      symbol: symbol,
      name: name,
      priceUsd: priceUsd ?? this.priceUsd,
      change24h: change24h ?? this.change24h,
      iconUrl: iconUrl,
      balance: balance ?? this.balance,
      walletAddress: walletAddress ?? this.walletAddress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoAssetEntity &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}