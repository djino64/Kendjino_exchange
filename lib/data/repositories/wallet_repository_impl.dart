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
      htgBalance: 0.0,
      usdBalance: 0.0,
      walletNumber: walletNumber,
      createdAt: DateTime.now(),
      usdtBalance: 0.0,
      btcBalance: 0.0,
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
        from: from,
        to: to,
        rate: cached,
        updatedAt: DateTime.now(),
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
      from: from,
      to: to,
      rate: rate,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<VirtualCardEntity> getVirtualCard(String userId) async {
    // Mock virtual card
    return VirtualCardEntity(
      id: 'vc_$userId',
      userId: userId,
      cardNumber: _generateCardNumber(),
      cardHolderName: 'KENDJINO USER',
      expiryMonth: '12',
      expiryYear: '27',
      cvv: '***',
      network: AppConstants.cardNetworkVisa,
      isActive: true,
      createdAt: DateTime.now(),
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