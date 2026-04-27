// ─── Exchange Rate Entity ─────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
class ExchangeRateEntity extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double buyRate;
  final double sellRate;
  final DateTime fetchedAt;
  final bool isCached;
 
  const ExchangeRateEntity({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.buyRate,
    required this.sellRate,
    required this.fetchedAt,
    this.isCached = false,
  });
 
  double convert(double amount) => amount * rate;
 
  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, fetchedAt];
}
 
// ─── Crypto Asset Entity ──────────────────────────────────────────────────────
class CryptoAssetEntity extends Equatable {
  final String symbol;
  final String name;
  final double priceUsd;
  final double change24h;
  final double? userBalance;
  final String iconUrl;
 
  const CryptoAssetEntity({
    required this.symbol,
    required this.name,
    required this.priceUsd,
    required this.change24h,
    this.userBalance,
    required this.iconUrl,
  });
 
  bool get isPositive => change24h >= 0;
 
  @override
  List<Object?> get props => [symbol, name, priceUsd, change24h];
}