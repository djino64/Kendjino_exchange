// lib/domain/repositories/wallet_repository.dart
import '../entities/entities.dart';

abstract class WalletRepository {
  Future<WalletEntity> getWallet(String userId);
  Future<WalletEntity> createWallet(String userId);
  Future<void> updateBalance(String userId, String currency, double amount);
  Stream<WalletEntity> watchWallet(String userId);
  Future<ExchangeRateEntity> getExchangeRate(String from, String to);
  Future<VirtualCardEntity> getVirtualCard(String userId);
  Future<VirtualCardEntity> createVirtualCard(String userId);
}