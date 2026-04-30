// lib/data/repositories/wallet_repository_impl.dart
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/remote/firestore_source.dart';
import '../datasources/local/hive_storage.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirestoreSource _firestore;
  final HiveStorage _local;
  final _uuid = const Uuid();

  WalletRepositoryImpl({
    required FirestoreSource firestore,
    required HiveStorage local,
  })  : _firestore = firestore,
        _local = local;

  @override
  Future<WalletEntity> getWallet(String userId) async {
    final wallet = await _firestore.getWallet(userId);
    if (wallet != null) return wallet;
    return createWallet(userId);
  }

  @override
  Future<WalletEntity> createWallet(String userId) async {
    final walletNumber = _generateWalletNumber();
    final wallet = WalletModel(
      id: '',
      userId: userId,
      balances: const {},
      lastUpdated: DateTime.now(),
      walletNumber: walletNumber,
    );
    return _firestore.createWallet(wallet);
  }

  @override
  Future<void> updateBalance(
      String userId, String currency, double amount) async {
    final wallet = await _firestore.getWallet(userId);
    if (wallet == null) return;
    await _firestore.updateWalletBalance(wallet.id, currency, amount);
  }

  @override
  Stream<WalletEntity> watchWallet(String userId) {
    return _firestore.watchWallet(userId).asyncMap((w) async {
      if (w != null) return w;
      return createWallet(userId);
    });
  }

  @override
  Future<ExchangeRateEntity> getExchangeRate(String from, String to) async {
    // Try cache first
    final pair = '${from}_$to';
    final cached = _local.getCachedRate(pair);
    if (cached != null) {
      return ExchangeRateEntity(
        fromCurrency: from,
        toCurrency: to,
        rate: cached,
        buyRate: cached,
        sellRate: cached,
        fetchedAt: DateTime.now(),
        isCached: true,
      );
    }

    // Fallback to constants
    double rate = 1.0;
    if (from == 'HTG' && to == 'USD') rate = AppConstants.defaultHtgToUsd;
    if (from == 'USD' && to == 'HTG') rate = AppConstants.defaultUsdToHtg;
    if (from == 'USD' && to == 'USDT') rate = 1.0;
    if (from == 'BTC' && to == 'USD') rate = AppConstants.defaultBtcToUsd;

    await _local.cacheExchangeRate(pair, rate);

    return ExchangeRateEntity(
      fromCurrency: from,
      toCurrency: to,
      rate: rate,
      buyRate: rate,
      sellRate: rate,
      fetchedAt: DateTime.now(),
      isCached: false,
    );
  }

  @override
  Future<VirtualCardEntity> getVirtualCard(String userId) async {
    // Mock virtual card
    final cardNumber = _generateCardNumber();
    final stripped = cardNumber.replaceAll(' ', '');
    final last4 = stripped.substring(stripped.length - 4);
    return VirtualCardEntity(
      id: 'vc_$userId',
      userId: userId,
      maskedNumber: '**** **** **** $last4',
      last4: last4,
      expiryMonth: '12',
      expiryYear: '27',
      cardHolderName: 'KENDJINO USER',
      network: AppConstants.cardNetworkVisa,
      balance: 0.0,
      currency: 'USD',
      issuedAt: DateTime.now(),
    );
  }

  @override
  Future<VirtualCardEntity> createVirtualCard(String userId) async {
    return getVirtualCard(userId);
  }

  String _generateWalletNumber() {
    final id = _uuid.v4().replaceAll('-', '').substring(0, 10).toUpperCase();
    return 'KX$id';
  }

  String _generateCardNumber() {
    final rng = List.generate(4, (_) {
      final n = (1000 + (DateTime.now().microsecond % 9000));
      return n.toString();
    });
    return '4${rng.join(' ').substring(1)}';
  }
}