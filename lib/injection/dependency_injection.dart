// lib/injection/dependency_injection.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/local/hive_storage.dart';
import '../data/datasources/remote/firestore_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/wallet_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/wallet_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/get_wallet_usecase.dart';
import '../domain/usecases/send_money_usecase.dart';
import '../domain/usecases/convert_currency_usecase.dart';
import '../services/firebase/firestore_service.dart';
import '../services/storage/local_storage_service.dart';
import '../core/network/network_info.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

final localStorageProvider =
    Provider<LocalStorageService>((ref) => LocalStorageService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final hiveStorageProvider = Provider<HiveStorage>((ref) => HiveStorage());

final firestoreSourceProvider =
    Provider<FirestoreSource>((ref) => FirestoreSource());

// ── Repositories ───────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firestore: ref.read(firestoreSourceProvider),
  );
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(
    firestore: ref.read(firestoreSourceProvider),
    local: ref.read(hiveStorageProvider),
  );
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    firestore: ref.read(firestoreSourceProvider),
    local: ref.read(hiveStorageProvider),
  );
});

// ── Use Cases ──────────────────────────────────────────────────────────────
final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.read(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.read(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

final getWalletUseCaseProvider = Provider<GetWalletUseCase>((ref) {
  return GetWalletUseCase(ref.read(walletRepositoryProvider));
});

final sendMoneyUseCaseProvider = Provider<SendMoneyUseCase>((ref) {
  return SendMoneyUseCase(
    ref.read(transactionRepositoryProvider),
    ref.read(walletRepositoryProvider),
  );
});

final convertCurrencyUseCaseProvider = Provider<ConvertCurrencyUseCase>((ref) {
  return ConvertCurrencyUseCase(ref.read(walletRepositoryProvider));
});