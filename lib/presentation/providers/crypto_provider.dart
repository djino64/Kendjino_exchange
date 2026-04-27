// lib/presentation/providers/crypto_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../injection/dependency_injection.dart';
import '../../services/crypto/crypto_service.dart';

final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

// ── Market Prices ──────────────────────────────────────────────────────────
final cryptoMarketProvider =
    FutureProvider.autoDispose<List<CryptoAssetEntity>>((ref) async {
  final service = ref.read(cryptoServiceProvider);
  return service.getMarketPrices();
});

// ── Simple Prices Map ──────────────────────────────────────────────────────
final cryptoSimplePricesProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final service = ref.read(cryptoServiceProvider);
  return service.getSimplePrices();
});

// ── Price History ──────────────────────────────────────────────────────────
final cryptoHistoryProvider = FutureProvider.autoDispose
    .family<List<double>, String>((ref, symbol) async {
  final service = ref.read(cryptoServiceProvider);
  final coinId = symbol == 'BTC' ? 'bitcoin' : 'tether';
  return service.getPriceHistory(coinId: coinId);
});

// ── Crypto Portfolio State ─────────────────────────────────────────────────
class CryptoPortfolioState {
  final List<CryptoAssetEntity> assets;
  final bool isLoading;
  final String? error;
  final bool isBuying;
  final bool isSelling;

  const CryptoPortfolioState({
    this.assets = const [],
    this.isLoading = false,
    this.error,
    this.isBuying = false,
    this.isSelling = false,
  });

  CryptoPortfolioState copyWith({
    List<CryptoAssetEntity>? assets,
    bool? isLoading,
    String? error,
    bool? isBuying,
    bool? isSelling,
  }) =>
      CryptoPortfolioState(
        assets: assets ?? this.assets,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isBuying: isBuying ?? this.isBuying,
        isSelling: isSelling ?? this.isSelling,
      );

  double get totalUsdValue =>
      assets.fold(0.0, (sum, a) => sum + (a.balance ?? 0) * a.priceUsd);
}

class CryptoNotifier extends StateNotifier<CryptoPortfolioState> {
  final Ref _ref;

  CryptoNotifier(this._ref) : super(const CryptoPortfolioState()) {
    loadPrices();
  }

  Future<void> loadPrices() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = _ref.read(cryptoServiceProvider);
      final prices = await service.getMarketPrices();
      // Attach mock balances for demo
      final withBalances = prices.map((a) {
        if (a.symbol == 'BTC') return a.copyWith(balance: 0.0025);
        if (a.symbol == 'USDT') return a.copyWith(balance: 50.0);
        return a;
      }).toList();
      state = state.copyWith(assets: withBalances, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les prix crypto',
      );
    }
  }

  Future<bool> buyCrypto({
    required String symbol,
    required double amountUsd,
  }) async {
    state = state.copyWith(isBuying: true, error: null);
    try {
      final service = _ref.read(cryptoServiceProvider);
      final asset = state.assets.firstWhere((a) => a.symbol == symbol);
      final result = await service.buyCrypto(
        userId: 'current',
        symbol: symbol,
        amountUsd: amountUsd,
        currentPriceUsd: asset.priceUsd,
      );
      if (result.success) {
        // Update local balance
        final updated = state.assets.map((a) {
          if (a.symbol == symbol) {
            return a.copyWith(
                balance: (a.balance ?? 0) + result.cryptoAmount);
          }
          return a;
        }).toList();
        state = state.copyWith(assets: updated, isBuying: false);
        return true;
      }
      state = state.copyWith(isBuying: false, error: 'Achat échoué');
      return false;
    } catch (e) {
      state = state.copyWith(isBuying: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sellCrypto({
    required String symbol,
    required double cryptoAmount,
  }) async {
    state = state.copyWith(isSelling: true, error: null);
    try {
      final service = _ref.read(cryptoServiceProvider);
      final asset = state.assets.firstWhere((a) => a.symbol == symbol);
      final result = await service.sellCrypto(
        userId: 'current',
        symbol: symbol,
        cryptoAmount: cryptoAmount,
        currentPriceUsd: asset.priceUsd,
      );
      if (result.success) {
        final updated = state.assets.map((a) {
          if (a.symbol == symbol) {
            final newBal = (a.balance ?? 0) - cryptoAmount;
            return a.copyWith(balance: newBal.clamp(0, double.infinity));
          }
          return a;
        }).toList();
        state = state.copyWith(assets: updated, isSelling: false);
        return true;
      }
      state = state.copyWith(isSelling: false, error: 'Vente échouée');
      return false;
    } catch (e) {
      state = state.copyWith(isSelling: false, error: e.toString());
      return false;
    }
  }
}

final cryptoProvider =
    StateNotifierProvider<CryptoNotifier, CryptoPortfolioState>((ref) {
  return CryptoNotifier(ref);
});