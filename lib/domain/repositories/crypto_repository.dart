// lib/domain/repositories/crypto_repository.dart
import '../entities/entities.dart';

abstract class CryptoRepository {
  Future<List<CryptoAssetEntity>> getMarketPrices();
  Future<Map<String, double>> getSimplePrices();
  Future<List<double>> getPriceHistory(String symbol, {int days = 7});
}