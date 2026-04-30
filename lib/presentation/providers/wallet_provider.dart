// lib/presentation/providers/wallet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../injection/dependency_injection.dart';
import 'auth_provider.dart';

// ── Wallet Stream ──────────────────────────────────────────────────────────
final walletStreamProvider = StreamProvider<WalletEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(getWalletUseCaseProvider).watch(user.uid);
});

// ── Wallet State Notifier ──────────────────────────────────────────────────
class WalletState {
  final WalletEntity? wallet;
  final bool isLoading;
  final String? error;
  final ExchangeRateEntity? htgUsdRate;

  const WalletState({
    this.wallet,
    this.isLoading = false,
    this.error,
    this.htgUsdRate,
  });

  WalletState copyWith({
    WalletEntity? wallet,
    bool? isLoading,
    String? error,
    ExchangeRateEntity? htgUsdRate,
  }) =>
      WalletState(
        wallet: wallet ?? this.wallet,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        htgUsdRate: htgUsdRate ?? this.htgUsdRate,
      );

  double get totalUsd {
    if (wallet == null) return 0;
    final rate = htgUsdRate?.rate ?? 0.0075;
    return (wallet!.getBalance('HTG') * rate) + wallet!.getBalance('USD');
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref _ref;

  WalletNotifier(this._ref) : super(const WalletState()) {
    _load();
  }

  Future<void> _load() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final wallet =
          await _ref.read(getWalletUseCaseProvider).call(user.uid);
      final rate = await _ref
          .read(convertCurrencyUseCaseProvider)
          .getRate('HTG', 'USD');
      state = state.copyWith(
        wallet: wallet,
        htgUsdRate: rate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de chargement du portefeuille',
      );
    }
  }

  Future<void> refresh() => _load();
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});