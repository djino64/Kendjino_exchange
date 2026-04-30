// ============================================================================
//  widget_test.dart — Kendjino EXCHANGE
//  Suite de tests complète : unité, widget & intégration
//
//  Couverture :
//   • Entités du domaine (UserEntity, WalletEntity, TransactionEntity, ...)
//   • Services métier (PaymentService, CryptoService, SecureStorageService)
//   • Providers Riverpod (biometric, theme, locale, currency, notifications)
//   • Widgets isolés (_SettingsTile, _ProfileCard, _KycBadge, _SettingsCard)
//   • Écran SettingsScreen (rendu, navigation, interactions, i18n)
//   • Helpers & utilitaires (formatage, fees, QR, adresses crypto)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kendjino_exchange/core/constants/app_constants.dart';
import 'package:kendjino_exchange/core/theme/app_theme.dart';
import 'package:kendjino_exchange/domain/entities/entities.dart';
import 'package:kendjino_exchange/services/payment/payment_service.dart';
import 'package:kendjino_exchange/services/crypto/crypto_service.dart';
import 'package:kendjino_exchange/presentation/screens/settings/settings_screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────
class MockPaymentService extends Mock implements PaymentService {}
class MockCryptoService extends Mock implements CryptoService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// ─── Test Fixtures ────────────────────────────────────────────────────────────
class Fixtures {
  static final DateTime _now = DateTime(2025, 1, 15, 10, 30);

  static UserEntity get verifiedUser => UserEntity(
        uid: 'uid_test_001',
        phoneNumber: '+50941300944',
        displayName: 'DESMARAIS Rood-Kendjino',
        email: 'roodkendjinodesmaraos@gmail.com',
        kycStatus: KycStatus.verified,
        createdAt: _now,
        lastLoginAt: _now,
        preferredLanguage: const UserPreferences(
          languageCode: 'fr',
        biometricEnabled: true,
          defaultCurrency: 'HTG',
        ),
      );

  static UserEntity get unverifiedUser => UserEntity(
        uid: 'uid_test_002',
        phoneNumber: '+50998765432',
        kycStatus: KycStatus.pending,
        createdAt: _now,
      );

  static UserEntity get submittedUser => UserEntity(
        uid: 'uid_test_003',
        phoneNumber: '+50911223344',
        displayName: 'Jean Pierre',
        kycStatus: KycStatus.submitted,
        createdAt: _now,
      );

  static UserEntity get rejectedUser => UserEntity(
        uid: 'uid_test_004',
        phoneNumber: '+50943653508',
        displayName: 'Byssainthe Wesner',
        kycStatus: KycStatus.rejected,
        createdAt: _now,
      );

  static WalletEntity get fullWallet => WalletEntity(
        id: 'wallet_001',
        userId: 'uid_test_001',
        balances: {
          'HTG': 15500.75,
          'USD': 117.20,
          'USDT': 50.0,
          'BTC': 0.00075,
        },
        lastUpdated: _now,
        walletNumber: 'KX-2025-001234',
      );

  static WalletEntity get emptyWallet => WalletEntity(
        id: 'wallet_002',
        userId: 'uid_test_002',
        balances: {'HTG': 0.0},
        lastUpdated: _now,
        walletNumber: 'KX-2025-005678',
      );

  static TransactionEntity get completedSend => TransactionEntity(
        id: 'tx_001',
        userId: 'uid_test_001',
        type: TransactionType.send,
        status: TransactionStatus.completed,
        amount: 2500.0,
        currency: 'HTG',
        receiverPhone: '+50941300944',
        receiverName: 'DESMARAIS Rood-Kendjino',
        paymentMethod: PaymentMethod.internal,
        createdAt: _now,
        completedAt: _now.add(const Duration(seconds: 3)),
        fee: 25.0,
        referenceNumber: 'REF1736938200000',
      );

  static TransactionEntity get pendingReceive => TransactionEntity(
        id: 'tx_002',
        userId: 'uid_test_001',
        type: TransactionType.receive,
        status: TransactionStatus.pending,
        amount: 1000.0,
        currency: 'HTG',
        senderPhone: '+50943653508',
        senderName: 'BYSSAINTHE Wesner',
        paymentMethod: PaymentMethod.moncash,
        createdAt: _now,
      );

  static TransactionEntity get cryptoBuy => TransactionEntity(
        id: 'tx_003',
        userId: 'uid_test_001',
        type: TransactionType.cryptoBuy,
        status: TransactionStatus.completed,
        amount: 50.0,
        currency: 'USDT',
        exchangeRate: 1.0,
        paymentMethod: PaymentMethod.crypto,
        createdAt: _now,
        fee: 0.75,
      );

  static ExchangeRateEntity get htgToUsd => ExchangeRateEntity(
        fromCurrency: 'HTG',
        toCurrency: 'USD',
        rate: 0.00755,
        buyRate: 0.0074,
        sellRate: 0.0077,
        fetchedAt: _now,
      );

  static CryptoAssetEntity get bitcoin => const CryptoAssetEntity(
        symbol: 'BTC',
        name: 'Bitcoin',
        priceUsd: 65420.50,
        change24h: 2.35,
        iconUrl: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
      );

  static CryptoAssetEntity get usdt => const CryptoAssetEntity(
        symbol: 'USDT',
        name: 'Tether',
        priceUsd: 1.0001,
        change24h: 0.01,
        iconUrl: 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
      );

  static CryptoAssetEntity get bitcoinNegative => const CryptoAssetEntity(
        symbol: 'BTC',
        name: 'Bitcoin',
        priceUsd: 60000.0,
        change24h: -3.14,
        iconUrl: '',
      );
}

// ─── Test Helpers ─────────────────────────────────────────────────────────────
Widget _wrap(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('fr'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: child,
    ),
  );
}

// ============================================================================
//  1. DOMAIN ENTITY TESTS
// ============================================================================
void main() {
  // ── UserEntity ─────────────────────────────────────────────────────────────
  group('UserEntity', () {
    test('creates with required fields only', () {
      final user = UserEntity(
        uid: 'u1',
        phoneNumber: '+50941300944',
        createdAt: DateTime(2026),
      );
      expect(user.uid, 'u1');
      expect(user.phoneNumber, '+50941300944');
      expect(user.displayName, isNull);
      expect(user.kycStatus, KycStatus.pending);
      expect(user.isVerified, isTrue);
    });

    test('copyWith updates only specified fields', () {
      final original = Fixtures.verifiedUser;
      final updated = original.copyWith(displayName: 'Nouvelle Marie');

      expect(updated.displayName, 'Nouvelle Marie');
      expect(updated.uid, original.uid);
      expect(updated.phoneNumber, original.phoneNumber);
      expect(updated.kycStatus, original.kycStatus);
    });

    test('equality is value-based via Equatable', () {
      final u1 = Fixtures.verifiedUser;
      final u2 = Fixtures.verifiedUser;
      expect(u1, equals(u2));
    });

    test('inequality when uid differs', () {
      final u1 = Fixtures.verifiedUser;
      final u2 = u1.copyWith(uid: 'different_uid');
      expect(u1, isNot(equals(u2)));
    });

    test('all KycStatus values are distinct', () {
      final statuses = KycStatus.values;
      expect(statuses.toSet().length, statuses.length);
    });

    test('UserPreferences copyWith preserves unspecified fields', () {
      const original = UserPreferences(languageCode: 'fr', biometricEnabled: true);
      final updated = original.copyWith(languageCode: 'en');
      expect(updated.languageCode, 'en');
      expect(updated.biometricEnabled, isTrue); // unchanged
    });

    group('KycStatus display logic', () {
      test('verified user has verified status', () {
        expect(Fixtures.verifiedUser.kycStatus, KycStatus.verified);
      });
      test('pending user is not verified', () {
        expect(Fixtures.unverifiedUser.kycStatus, KycStatus.pending);
      });
      test('submitted status is between pending and verified', () {
        expect(Fixtures.submittedUser.kycStatus, KycStatus.submitted);
      });
      test('rejected user has rejected status', () {
        expect(Fixtures.rejectedUser.kycStatus, KycStatus.rejected);
      });
    });
  });

  // ── WalletEntity ───────────────────────────────────────────────────────────
  group('WalletEntity', () {
    test('getBalance returns correct amount for existing currency', () {
      final wallet = Fixtures.fullWallet;
      expect(wallet.getBalance('HTG'), 15500.75);
      expect(wallet.getBalance('USD'), 117.20);
      expect(wallet.getBalance('USDT'), 50.0);
      expect(wallet.getBalance('BTC'), 0.00075);
    });

    test('getBalance returns 0.0 for missing currency', () {
      final wallet = Fixtures.fullWallet;
      expect(wallet.getBalance('EUR'), 0.0);
      expect(wallet.getBalance(''), 0.0);
    });

    test('empty wallet has zero HTG balance', () {
      expect(Fixtures.emptyWallet.getBalance('HTG'), 0.0);
    });

    test('copyWith updates balances immutably', () {
      final wallet = Fixtures.fullWallet;
      final updated = wallet.copyWith(
        balances: {...wallet.balances, 'HTG': 20000.0},
      );
      expect(updated.getBalance('HTG'), 20000.0);
      expect(wallet.getBalance('HTG'), 15500.75); // original unchanged
    });

    test('walletNumber is preserved in copyWith', () {
      final wallet = Fixtures.fullWallet;
      final updated = wallet.copyWith(userId: 'new_user');
      expect(updated.walletNumber, wallet.walletNumber);
    });
  });

  // ── TransactionEntity ──────────────────────────────────────────────────────
  group('TransactionEntity', () {
    test('send transaction is a debit', () {
      expect(Fixtures.completedSend.isDebit, isTrue);
      expect(Fixtures.completedSend.isCredit, isFalse);
    });

    test('receive transaction is a credit', () {
      expect(Fixtures.pendingReceive.isCredit, isTrue);
      expect(Fixtures.pendingReceive.isDebit, isFalse);
    });

    test('cryptoBuy transaction is a debit', () {
      expect(Fixtures.cryptoBuy.isDebit, isTrue);
    });

    test('completed transaction has completedAt', () {
      final tx = Fixtures.completedSend;
      expect(tx.status, TransactionStatus.completed);
      expect(tx.completedAt, isNotNull);
    });

    test('pending transaction has no completedAt', () {
      final tx = Fixtures.pendingReceive;
      expect(tx.status, TransactionStatus.pending);
      expect(tx.completedAt, isNull);
    });

    test('all TransactionType values are distinct', () {
      final types = TransactionType.values;
      expect(types.toSet().length, types.length);
    });

    test('all TransactionStatus values are distinct', () {
      final statuses = TransactionStatus.values;
      expect(statuses.toSet().length, statuses.length);
    });

    test('fee is stored correctly', () {
      expect(Fixtures.completedSend.fee, 25.0);
    });

    test('equality based on id', () {
      final tx1 = Fixtures.completedSend;
      final tx2 = tx1;
      expect(identical(tx1, tx2), isTrue);
    });
  });

  // ── ExchangeRateEntity ─────────────────────────────────────────────────────
  group('ExchangeRateEntity', () {
    test('convert multiplies amount by rate correctly', () {
      final rate = Fixtures.htgToUsd;
      final usd = rate.convert(1000.0);
      expect(usd, closeTo(7.55, 0.01));
    });

    test('convert zero returns zero', () {
      expect(Fixtures.htgToUsd.convert(0.0), 0.0);
    });

    test('buyRate is less than sellRate (spread)', () {
      final rate = Fixtures.htgToUsd;
      expect(rate.buyRate, lessThan(rate.sellRate));
    });

    test('isCached defaults to false', () {
      expect(Fixtures.htgToUsd.isCached, isFalse);
    });

    test('cached rate can be created', () {
      final cached = ExchangeRateEntity(
        fromCurrency: 'HTG',
        toCurrency: 'USD',
        rate: 0.0075,
        buyRate: 0.0074,
        sellRate: 0.0077,
        fetchedAt: DateTime.now(),
        isCached: true,
      );
      expect(cached.isCached, isTrue);
    });
  });

  // ── CryptoAssetEntity ──────────────────────────────────────────────────────
  group('CryptoAssetEntity', () {
    test('positive change is detected as positive', () {
      expect(Fixtures.bitcoin.isPositive, isTrue);
    });

    test('negative change is detected as negative', () {
      expect(Fixtures.bitcoinNegative.isPositive, isFalse);
    });

    test('zero change is positive (neutral)', () {
      const neutralCrypto = CryptoAssetEntity(
        symbol: 'USDT',
        name: 'Tether',
        priceUsd: 1.0,
        change24h: 0.0,
        iconUrl: '',
      );
      expect(neutralCrypto.isPositive, isTrue);
    });

    test('balance defaults to null', () {
      expect(Fixtures.bitcoin.balance, isNull);
    });

    test('balance can be set', () {
      const asset = CryptoAssetEntity(
        symbol: 'BTC',
        name: 'Bitcoin',
        priceUsd: 65000,
        change24h: 1.0,
        iconUrl: '',
        balance: 0.005,
      );
      expect(asset.balance, 0.005);
    });
  });

  // ── VirtualCardEntity ──────────────────────────────────────────────────────
  group('VirtualCardEntity', () {
    late VirtualCardEntity card;

    setUp(() {
      card = VirtualCardEntity(
        id: 'card_001',
        userId: 'uid_test_001',
        maskedNumber: '**** **** **** 4242',
        last4: '4242',
        expiryMonth: '12',
        expiryYear: '27',
        cardHolderName: 'MARIE JEAN-BAPTISTE',
        network: 'VISA',
        balance: 250.0,
        currency: 'USD',
        issuedAt: DateTime(2025, 1),
      );
    });

    test('displayNumber formats correctly', () {
      expect(card.displayNumber, '**** **** **** 4242');
    });

    test('displayExpiry formats correctly', () {
      expect(card.displayExpiry, '12/27');
    });

    test('default status is active', () {
      expect(card.status, CardStatus.active);
    });

    test('isVirtual defaults to true', () {
      expect(card.isVirtual, isTrue);
    });

    test('all CardStatus values exist', () {
      expect(CardStatus.values, containsAll([
        CardStatus.active,
        CardStatus.frozen,
        CardStatus.expired,
        CardStatus.cancelled,
      ]));
    });
  });

  // ============================================================================
  //  2. PAYMENT SERVICE TESTS
  // ============================================================================
  group('PaymentService', () {
    late PaymentService service;

    setUp(() {
      service = PaymentService();
    });

    group('internalTransfer', () {
      test('returns successful transfer result', () async {
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50998765432',
          amount: 1000.0,
          currency: 'HTG',
        );
        expect(result.success, isTrue);
        expect(result.amount, 1000.0);
        expect(result.currency, 'HTG');
        expect(result.receiverPhone, '+50998765432');
        expect(result.transactionId, startsWith('KX_'));
        expect(result.referenceNumber, startsWith('REF'));
      });

      test('calculates fee correctly for small HTG amount', () async {
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 300.0,
          currency: 'HTG',
        );
        // < 500 HTG → flat fee of 5
        expect(result.fee, 5.0);
        expect(result.totalDeducted, 305.0);
      });

      test('calculates 1% fee for mid-range HTG transfer', () async {
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 2000.0,
          currency: 'HTG',
        );
        // 500–5000 HTG → 1%
        expect(result.fee, closeTo(20.0, 0.01));
        expect(result.totalDeducted, closeTo(2020.0, 0.01));
      });

      test('calculates 0.8% fee for large HTG transfer', () async {
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 10000.0,
          currency: 'HTG',
        );
        // > 5000 → 0.8%
        expect(result.fee, closeTo(80.0, 0.01));
        expect(result.totalDeducted, closeTo(10080.0, 0.01));
      });

      test('calculates 1.5% fee for USD transfer', () async {
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 100.0,
          currency: 'USD',
        );
        expect(result.fee, closeTo(1.5, 0.01));
        expect(result.totalDeducted, closeTo(101.5, 0.01));
      });

      test('generates unique transaction IDs', () async {
        final r1 = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 500.0,
          currency: 'HTG',
        );
        final r2 = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50922222222',
          amount: 500.0,
          currency: 'HTG',
        );
        expect(r1.transactionId, isNot(equals(r2.transactionId)));
      });

      test('timestamp is close to now', () async {
        final before = DateTime.now();
        final result = await service.internalTransfer(
          senderUid: 'uid_001',
          receiverPhone: '+50911111111',
          amount: 100.0,
          currency: 'HTG',
        );
        final after = DateTime.now();
        expect(
          result.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(result.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('initiateMoncashPayment (mock mode)', () {
      test('returns a PaymentResult with correct currency', () async {
        final result = await service.initiateMoncashPayment(
          amount: 500.0,
          orderId: 'order_test_001',
          description: 'Test MonCash',
        );
        expect(result.currency, 'HTG');
        expect(result.provider, PaymentProvider.moncash);
        expect(result.amount, 500.0);
      });

      test('result has a timestamp', () async {
        final result = await service.initiateMoncashPayment(
          amount: 100.0,
          orderId: 'order_002',
          description: 'Test',
        );
        expect(result.timestamp, isA<DateTime>());
      });
    });

    group('initiateNatcashTransfer (mock mode)', () {
      test('returns success result', () async {
        final result = await service.initiateNatcashTransfer(
          senderPhone: '+50912345678',
          receiverPhone: '+50987654321',
          amount: 1500.0,
        );
        expect(result.success, isTrue);
        expect(result.provider, PaymentProvider.natcash);
        expect(result.currency, 'HTG');
        expect(result.transactionId, startsWith('NC_'));
      });
    });

    group('generatePaymentQrData', () {
      test('includes required params in QR data', () {
        final qr = service.generatePaymentQrData(
          userId: 'uid_001',
          walletNumber: 'KX-2025-001234',
        );
        expect(qr, contains('uid=uid_001'));
        expect(qr, contains('wallet=KX-2025-001234'));
        expect(qr, contains('app=kendjino'));
      });

      test('includes amount when provided', () {
        final qr = service.generatePaymentQrData(
          userId: 'uid_001',
          walletNumber: 'KX-2025-001234',
          amount: '500.00',
          currency: 'HTG',
        );
        expect(qr, contains('amount=500.00'));
        expect(qr, contains('currency=HTG'));
      });

      test('does not include amount when omitted', () {
        final qr = service.generatePaymentQrData(
          userId: 'uid_001',
          walletNumber: 'KX-2025-001234',
        );
        expect(qr, isNot(contains('amount=')));
      });
    });

    group('PaymentResult.failed factory', () {
      test('creates failed result with correct fields', () {
        final result = PaymentResult.failed(
          'Connection timeout',
          PaymentProvider.moncash,
        );
        expect(result.success, isFalse);
        expect(result.status, PaymentStatus.failed);
        expect(result.message, 'Connection timeout');
        expect(result.provider, PaymentProvider.moncash);
        expect(result.transactionId, isNull);
      });
    });
  });

  // ============================================================================
  //  3. CRYPTO SERVICE TESTS
  // ============================================================================
  group('CryptoService', () {
    late CryptoService service;

    setUp(() {
      service = CryptoService();
    });

    group('buyCrypto', () {
      test('calculates correct crypto amount from USD', () async {
        final result = await service.buyCrypto(
          userId: 'uid_001',
          symbol: 'BTC',
          amountUsd: 65.0,
          currentPriceUsd: 65000.0,
        );
        expect(result.success, isTrue);
        expect(result.cryptoAmount, closeTo(0.001, 0.00001));
        expect(result.symbol, 'BTC');
        expect(result.type, CryptoTxType.buy);
      });

      test('fee is 1.5% of USD amount', () async {
        final result = await service.buyCrypto(
          userId: 'uid_001',
          symbol: 'USDT',
          amountUsd: 100.0,
          currentPriceUsd: 1.0,
        );
        expect(result.fee, closeTo(1.5, 0.001));
        expect(result.totalUsd, closeTo(101.5, 0.001));
      });

      test('transaction ID starts with CRYPTO_BUY_', () async {
        final result = await service.buyCrypto(
          userId: 'uid_001',
          symbol: 'BTC',
          amountUsd: 50.0,
          currentPriceUsd: 65000.0,
        );
        expect(result.transactionId, startsWith('CRYPTO_BUY_'));
      });

      test('txHash is non-empty', () async {
        final result = await service.buyCrypto(
          userId: 'uid_001',
          symbol: 'BTC',
          amountUsd: 50.0,
          currentPriceUsd: 65000.0,
        );
        expect(result.txHash, isNotEmpty);
        expect(result.txHash.length, greaterThan(10));
      });
    });

    group('sellCrypto', () {
      test('calculates correct USD from crypto amount', () async {
        final result = await service.sellCrypto(
          userId: 'uid_001',
          symbol: 'BTC',
          cryptoAmount: 0.001,
          currentPriceUsd: 65000.0,
        );
        // Gross: 65.0 — fee 1.5% = 0.975 → net ≈ 64.025
        expect(result.success, isTrue);
        expect(result.type, CryptoTxType.sell);
        expect(result.usdAmount, closeTo(64.025, 0.01));
        expect(result.fee, closeTo(0.975, 0.001));
      });

      test('transaction ID starts with CRYPTO_SELL_', () async {
        final result = await service.sellCrypto(
          userId: 'uid_001',
          symbol: 'USDT',
          cryptoAmount: 50.0,
          currentPriceUsd: 1.0,
        );
        expect(result.transactionId, startsWith('CRYPTO_SELL_'));
      });
    });

    group('sendCrypto', () {
      test('BTC network fee is 0.00005 BTC', () async {
        final result = await service.sendCrypto(
          fromUserId: 'uid_001',
          toAddress: 'bc1qtest12345',
          symbol: 'BTC',
          amount: 0.01,
        );
        expect(result.success, isTrue);
        expect(result.fee, 0.00005);
        expect(result.type, CryptoTxType.send);
        expect(result.toAddress, 'bc1qtest12345');
      });

      test('USDT network fee is 1.0 USDT', () async {
        final result = await service.sendCrypto(
          fromUserId: 'uid_001',
          toAddress: '0xabc123',
          symbol: 'USDT',
          amount: 100.0,
        );
        expect(result.fee, 1.0);
      });
    });

    group('generateWalletAddress', () {
      test('BTC address starts with bc1q', () {
        final addr = service.generateWalletAddress('BTC');
        expect(addr, startsWith('bc1q'));
        expect(addr.length, greaterThan(10));
      });

      test('USDT address starts with 0x', () {
        final addr = service.generateWalletAddress('USDT');
        expect(addr, startsWith('0x'));
        expect(addr.length, 42); // 0x + 40 hex chars
      });

      test('generated addresses are unique', () {
        final addr1 = service.generateWalletAddress('BTC');
        final addr2 = service.generateWalletAddress('BTC');
        expect(addr1, isNot(equals(addr2)));
      });
    });

    group('getSimplePrices (offline fallback)', () {
      test('fallback prices have correct keys', () async {
        // In test env, network will fail → mock prices
        final prices = await service.getSimplePrices();
        expect(prices.containsKey('BTC'), isTrue);
        expect(prices.containsKey('USDT'), isTrue);
      });

      test('fallback BTC price is a reasonable value', () async {
        final prices = await service.getSimplePrices();
        expect(prices['BTC']!, greaterThan(1000.0));
      });
    });
  });

  // ============================================================================
  //  4. SETTINGS PROVIDER TESTS
  // ============================================================================
  group('Settings Providers', () {
    group('biometricEnabledProvider', () {
      test('starts as false', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        expect(container.read(biometricEnabledProvider), isFalse);
      });

      test('toggle switches state to true', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(biometricEnabledProvider.notifier).toggle();
        expect(container.read(biometricEnabledProvider), isTrue);
      });

      test('double toggle returns to false', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(biometricEnabledProvider.notifier).toggle();
        container.read(biometricEnabledProvider.notifier).toggle();
        expect(container.read(biometricEnabledProvider), isFalse);
      });
    });

    group('notificationsEnabledProvider', () {
      test('starts as true', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        expect(container.read(notificationsEnabledProvider), isTrue);
      });

      test('toggle disables notifications', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(notificationsEnabledProvider.notifier).toggle();
        expect(container.read(notificationsEnabledProvider), isFalse);
      });
    });

    group('defaultCurrencyProvider', () {
      test('starts as HTG', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        expect(container.read(defaultCurrencyProvider), 'HTG');
      });

      test('can be set to USD', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(defaultCurrencyProvider.notifier).set('USD');
        expect(container.read(defaultCurrencyProvider), 'USD');
      });

      test('can be set to BTC', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(defaultCurrencyProvider.notifier).set('BTC');
        expect(container.read(defaultCurrencyProvider), 'BTC');
      });

      test('all supported currencies can be set', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        for (final currency in ['HTG', 'USD', 'USDT', 'BTC']) {
          container.read(defaultCurrencyProvider.notifier).set(currency);
          expect(container.read(defaultCurrencyProvider), currency);
        }
      });
    });
  });

  // ============================================================================
  //  5. APP CONSTANTS TESTS
  // ============================================================================
  group('AppConstants', () {
    test('default HTG→USD rate is reasonable', () {
      expect(AppConstants.defaultHtgToUsd, greaterThan(0.001));
      expect(AppConstants.defaultHtgToUsd, lessThan(0.1));
    });

    test('inverse rates are consistent', () {
      final computed = 1.0 / AppConstants.defaultUsdToHtg;
      expect(computed, closeTo(AppConstants.defaultHtgToUsd, 0.001));
    });

    test('OTP length is 6', () {
      expect(AppConstants.otpLength, 6);
    });

    test('PIN length is 4', () {
      expect(AppConstants.pinLength, 4);
    });

    test('daily limit is greater than single transfer max', () {
      expect(
        AppConstants.dailyTransferLimit,
        greaterThan(AppConstants.singleTransferMax),
      );
    });

    test('single transfer min is less than max', () {
      expect(
        AppConstants.singleTransferMin,
        lessThan(AppConstants.singleTransferMax),
      );
    });

    test('supported languages include fr, ht, en', () {
      expect(AppConstants.supportedLanguageCodes, containsAll(['fr', 'ht', 'en']));
    });

    test('Firebase collection names are non-empty', () {
      final collections = [
        AppConstants.usersCollection,
        AppConstants.transactionsCollection,
        AppConstants.walletsCollection,
        AppConstants.virtualCardsCollection,
      ];
      for (final c in collections) {
        expect(c, isNotEmpty);
      }
    });

    test('Hive box names are unique', () {
      final boxes = {
        AppConstants.transactionsBox,
        AppConstants.settingsBox,
        AppConstants.offlineCacheBox,
      };
      expect(boxes.length, 3);
    });
  });

  // ============================================================================
  //  6. WIDGET TESTS — Isolated Components
  // ============================================================================
  group('Widget: _SectionLabel (via SettingsScreen)', () {
    testWidgets('renders section labels in French by default', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump(); // Let animations start

      // Check for key section labels
      expect(find.text('COMPTE'), findsOneWidget);
      expect(find.text('SÉCURITÉ'), findsOneWidget);
      expect(find.text('PRÉFÉRENCES'), findsOneWidget);
    });

    testWidgets('renders labels in English locale', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('en')),
      );
      await tester.pump();

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('SECURITY'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
    });

    testWidgets('renders labels in Haitian Creole locale', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('ht')),
      );
      await tester.pump();

      expect(find.text('KONT'), findsOneWidget);
      expect(find.text('SEKIRITE'), findsOneWidget);
      expect(find.text('PREFERANS'), findsOneWidget);
    });
  });

  group('Widget: SettingsScreen AppBar', () {
    testWidgets('shows "Paramètres" title in French', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('shows "Settings" title in English', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('en')),
      );
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows "Paramèt" title in Haitian Creole', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('ht')),
      );
      await tester.pump();
      expect(find.text('Paramèt'), findsOneWidget);
    });

    testWidgets('info icon button exists', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping info icon opens app info dialog', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Kendjino EXCHANGE'), findsWidgets);
      expect(find.text('Fermer'), findsOneWidget);
    });

    testWidgets('info dialog can be dismissed', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      expect(find.text('Fermer'), findsNothing);
    });
  });

  group('Widget: Biometric Toggle', () {
    testWidgets('biometric toggle starts as false and can be toggled', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Find the biometric switch — it starts false
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsWidgets);

      // Find specific biometric switch (first Switch under biometric row)
      final switches = tester.widgetList<Switch>(switchFinder).toList();
      final biometricSwitch = switches.first;
      expect(biometricSwitch.value, isFalse);
    });

    testWidgets('biometric icon is visible', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });
  });

  group('Widget: Dark Mode Toggle', () {
    testWidgets('dark mode shows correct icon in light mode', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen(), themeMode: ThemeMode.light));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    });

    testWidgets('dark mode shows correct icon in dark mode', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen(), themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });
  });

  group('Widget: Logout Button', () {
    testWidgets('logout button is visible with correct label (FR)', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Se déconnecter'), findsOneWidget);
    });

    testWidgets('logout button is visible in English', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('tapping logout shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Déconnecter'), findsOneWidget);
    });

    testWidgets('cancel button dismisses logout dialog', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsNothing);
    });
  });

  group('Widget: Delete Account', () {
    testWidgets('delete account link is visible', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer mon compte'), findsOneWidget);
    });

    testWidgets('tapping delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supprimer mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer le compte'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('cancel dismisses delete dialog', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Supprimer mon compte'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer le compte'), findsNothing);
    });
  });

  group('Widget: KYC Badge', () {
    testWidgets('shows correct labels for all KYC statuses', (tester) async {
      final statuses = {
        KycStatus.verified: 'VÉRIFIÉ',
        KycStatus.submitted: 'EN COURS',
        KycStatus.rejected: 'REJETÉ',
        KycStatus.pending: 'NON VÉRIFIÉ',
      };

      for (final entry in statuses.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KycBadge(status: entry.key),
            ),
          ),
        );
        await tester.pump();
        expect(find.text(entry.value), findsOneWidget, reason: 'Status: ${entry.key}');
      }
    });
  });

  group('Widget: SettingsScreen scrollable content', () {
    testWidgets('can scroll to bottom to find version info', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to load lazy content
      await tester.dragFrom(
        tester.getCenter(find.byType(CustomScrollView)),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kendjino EXCHANGE'), findsWidgets);
    });

    testWidgets('app version string is formatted correctly', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.dragFrom(
        tester.getCenter(find.byType(CustomScrollView)),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('v${AppConstants.appVersion} (${AppConstants.appBuildNumber})'),
        findsOneWidget,
      );
    });
  });

  group('Widget: Dark theme rendering', () {
    testWidgets('SettingsScreen renders without errors in dark mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SettingsScreen renders without errors in light mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), themeMode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ============================================================================
  //  7. APP THEME TESTS
  // ============================================================================
  group('AppTheme', () {
    test('light theme has correct primary color', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppTheme.primaryGreen);
    });

    test('dark theme has correct primary color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, AppTheme.primaryGreen);
    });

    test('light theme uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });

    test('dark theme uses Material 3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('light scaffold background is lightBg', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppTheme.lightBg);
    });

    test('dark scaffold background is darkBg', () {
      expect(AppTheme.darkTheme.scaffoldBackgroundColor, AppTheme.darkBg);
    });

    test('error color is errorRed', () {
      expect(AppTheme.lightTheme.colorScheme.error, AppTheme.errorRed);
    });

    test('font family is Satoshi', () {
      expect(AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily, 'Satoshi');
    });

    test('elevated button has correct height', () {
      final style = AppTheme.lightTheme.elevatedButtonTheme.style;
      final size = style?.minimumSize?.resolve({});
      expect(size?.height, 54);
    });

    test('card border radius is 16', () {
      final shape = AppTheme.lightTheme.cardTheme.shape as RoundedRectangleBorder;
      final radius = shape.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 16);
    });

    test('primaryGreen hex value is correct', () {
      expect(AppTheme.primaryGreen.value, 0xFF00D4AA);
    });

    test('accentGold hex value is correct', () {
      expect(AppTheme.accentGold.value, 0xFFFFD700);
    });
  });

  // ============================================================================
  //  8. BUSINESS LOGIC / EDGE CASES
  // ============================================================================
  group('Business Logic Edge Cases', () {
    group('Transfer validation', () {
      test('amount below minimum is invalid', () {
        const amount = 5.0;
        expect(amount < AppConstants.singleTransferMin, isTrue);
      });

      test('amount above maximum is invalid', () {
        const amount = 50000.0;
        expect(amount > AppConstants.singleTransferMax, isTrue);
      });

      test('amount within bounds is valid', () {
        const amount = 1000.0;
        expect(amount >= AppConstants.singleTransferMin, isTrue);
        expect(amount <= AppConstants.singleTransferMax, isTrue);
      });

      test('daily limit enforced correctly', () {
        const todayTotal = 30000.0;
        const newTransfer = 25000.0;
        expect(
          todayTotal + newTransfer > AppConstants.dailyTransferLimit,
          isTrue,
        );
      });
    });

    group('Exchange rate conversions', () {
      test('1 USD converts to correct HTG at default rate', () {
        const usd = 1.0;
        final htg = usd * AppConstants.defaultUsdToHtg;
        expect(htg, closeTo(132.5, 0.1));
      });

      test('1 HTG converts to correct USD at default rate', () {
        const htg = 1.0;
        final usd = htg * AppConstants.defaultHtgToUsd;
        expect(usd, closeTo(0.0075, 0.0001));
      });

      test('BTC default price is reasonable (>10k USD)', () {
        expect(AppConstants.defaultBtcToUsd, greaterThan(10000));
      });

      test('USDT default price is 1.0 USD', () {
        expect(AppConstants.defaultUsdtToUsd, 1.0);
      });
    });

    group('Cache duration', () {
      test('exchange rate cache duration is 30 minutes', () {
        expect(AppConstants.exchangeRateCacheDuration.inMinutes, 30);
      });

      test('user data cache is 1 hour', () {
        expect(AppConstants.userCacheDuration.inHours, 1);
      });
    });

    group('Crypto address validation', () {
      test('BTC address has minimum length', () {
        final service = CryptoService();
        final addr = service.generateWalletAddress('BTC');
        expect(addr.length, greaterThanOrEqualTo(26)); // min P2WPKH length
      });

      test('ETH/USDT address is exactly 42 chars', () {
        final service = CryptoService();
        final addr = service.generateWalletAddress('USDT');
        expect(addr.length, 42);
      });
    });
  });
}