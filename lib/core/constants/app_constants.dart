class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Kendjino EXCHANGE';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Hive Boxes
  static const String transactionsBox = 'transactions';
  static const String settingsBox = 'settings';
  static const String offlineCacheBox = 'offline_cache';

  // Secure Storage Keys
  static const String pinKey = 'user_pin';
  static const String biometricKey = 'biometric_enabled';
  static const String sessionTokenKey = 'session_token';
  static const String userDataKey = 'user_data';
  static const String encryptionKeyKey = 'encryption_key';

  // Currencies
  static const String htgCurrency = 'HTG';
  static const String usdCurrency = 'USD';
  static const String usdtCurrency = 'USDT';
  static const String btcCurrency = 'BTC';

  // Default exchange rates (fallback offline)
  static const double defaultHtgToUsd = 0.0075; // 1 HTG ≈ 0.0075 USD
  static const double defaultUsdToHtg = 132.5;
  static const double defaultBtcToUsd = 65000.0;
  static const double defaultUsdtToUsd = 1.0;

  // Transaction limits (HTG)
  static const double dailyTransferLimit = 50000.0;
  static const double singleTransferMax = 25000.0;
  static const double singleTransferMin = 10.0;

  // OTP
  static const int otpLength = 6;
  static const int otpExpirySeconds = 120;
  static const int otpResendCooldown = 60;

  // PIN
  static const int pinLength = 4;
  static const int maxPinAttempts = 5;

  // API Endpoints (mock)
  static const String moncashMockBase = 'https://api.moncash.mock/v1';
  static const String natcashMockBase = 'https://api.natcash.mock/v1';
  static const String exchangeRateBase = 'https://api.exchangerate-api.com/v4';
  static const String cryptoPriceBase = 'https://api.coingecko.com/api/v3';
  static const String stripeBase = 'https://api.stripe.com/v1';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String walletsCollection = 'wallets';
  static const String notificationsCollection = 'notifications';
  static const String exchangeRatesCollection = 'exchange_rates';
  static const String virtualCardsCollection = 'virtual_cards';

  // Supported Locales
  static const List<String> supportedLanguageCodes = ['fr', 'ht', 'en'];

  // Colors (hex strings for constants)
  static const int primaryColorValue = 0xFF00D4AA;
  static const int secondaryColorValue = 0xFF1A1F2E;
  static const int accentColorValue = 0xFFFFD700;

  // Notification Channels
  static const String transactionChannel = 'transactions';
  static const String securityChannel = 'security';
  static const String promoChannel = 'promotions';

  // Card
  static const String virtualCardProvider = 'Kendjino Virtual';
  static const String cardNetworkVisa = 'VISA';

  // Feature flags
  static const bool cryptoEnabled = true;
  static const bool virtualCardEnabled = true;
  static const bool moncashEnabled = true;
  static const bool natcashEnabled = true;

  // Pagination
  static const int transactionPageSize = 20;

  // Cache durations
  static const Duration exchangeRateCacheDuration = Duration(minutes: 30);
  static const Duration userCacheDuration = Duration(hours: 1);
}