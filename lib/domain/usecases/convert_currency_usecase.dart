// lib/domain/usecases/convert_currency_usecase.dart
import '../entities/entities.dart';
import '../repositories/wallet_repository.dart';

class ConvertCurrencyUseCase {
  final WalletRepository _repo;
  ConvertCurrencyUseCase(this._repo);

  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    final rate = await _repo.getExchangeRate(from, to);
    return amount * rate.rate;
  }

  Future<ExchangeRateEntity> getRate(String from, String to) =>
      _repo.getExchangeRate(from, to);
}