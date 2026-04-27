// lib/domain/usecases/get_wallet_usecase.dart
import '../entities/entities.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository _repo;
  GetWalletUseCase(this._repo);

  Future<WalletEntity> call(String userId) => _repo.getWallet(userId);
  Stream<WalletEntity> watch(String userId) => _repo.watchWallet(userId);
}