// lib/data/models/crypto_model.dart
import '../../domain/entities/entities.dart';

class CryptoModel extends CryptoAssetEntity {
  const CryptoModel({
    required super.symbol,
    required super.name,
    required super.priceUsd,
    required super.change24h,
    required super.iconUrl,
    super.balance,
    super.walletAddress,
  });

  factory CryptoModel.fromCoinGecko(Map<String, dynamic> data) {
    return CryptoModel(
      symbol: (data['symbol'] as String).toUpperCase(),
      name: data['name'] as String,
      priceUsd: (data['current_price'] as num).toDouble(),
      change24h: (data['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      iconUrl: data['image'] ?? '',
    );
  }

  factory CryptoModel.fromEntity(CryptoAssetEntity entity) {
    return CryptoModel(
      symbol: entity.symbol,
      name: entity.name,
      priceUsd: entity.priceUsd,
      change24h: entity.change24h,
      iconUrl: entity.iconUrl,
      balance: entity.balance,
      walletAddress: entity.walletAddress,
    );
  }
}