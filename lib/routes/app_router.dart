// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../presentation/screens/auth/splash_screen.dart';
// import '../../presentation/screens/auth/onboarding_screen.dart';
// import '../../presentation/screens/auth/phone_auth_screen.dart';
// import '../../presentation/screens/auth/otp_verification_screen.dart';
// import '../../presentation/screens/auth/create_pin_screen.dart';
// import '../../presentation/screens/auth/biometric_setup_screen.dart';
// import '../../presentation/screens/auth/kyc_screen.dart';
// import '../../presentation/screens/wallet/wallet_screen.dart';
// import '../../presentation/screens/transfer/send_money_screen.dart';
// import '../../presentation/screens/transfer/receive_money_screen.dart';
// import '../../presentation/screens/transfer/confirm_transfer_screen.dart';
// import '../../presentation/screens/transfer/transfer_success_screen.dart';
// import '../../presentation/screens/exchange/currency_exchange_screen.dart';
// import '../../presentation/screens/crypto/crypto_screen.dart';
// import '../../presentation/screens/crypto/crypto_buy_screen.dart';
// import '../../presentation/screens/card/virtual_card_screen.dart';
// import '../../presentation/screens/history/transaction_history_screen.dart';
// import '../../presentation/screens/history/transaction_detail_screen.dart';
// import '../../presentation/screens/notifications/notifications_screen.dart';
// import '../../presentation/screens/settings/settings_screen.dart';
// import '../../presentation/screens/settings/profile_screen.dart';
// import '../../presentation/screens/settings/security_screen.dart';
// import '../../presentation/screens/settings/language_screen.dart';
// import '../../presentation/widgets/common/main_shell.dart';
// import '../../presentation/providers/auth_provider.dart';

// part 'app_router.g.dart';

// // Route names
// class AppRoutes {
//   static const splash = '/';
//   static const onboarding = '/onboarding';
//   static const phoneAuth = '/auth/phone';
//   static const otpVerification = '/auth/otp';
//   static const createPin = '/auth/pin/create';
//   static const biometricSetup = '/auth/biometric';
//   static const kyc = '/auth/kyc';
//   static const home = '/home';
//   static const wallet = '/wallet';
//   static const sendMoney = '/transfer/send';
//   static const receiveMoney = '/transfer/receive';
//   static const confirmTransfer = '/transfer/confirm';
//   static const transferSuccess = '/transfer/success';
//   static const exchange = '/exchange';
//   static const crypto = '/crypto';
//   static const cryptoBuy = '/crypto/buy';
//   static const virtualCard = '/card';
//   static const history = '/history';
//   static const transactionDetail = '/history/detail';
//   static const notifications = '/notifications';
//   static const settings = '/settings';
//   static const profile = '/settings/profile';
//   static const security = '/settings/security';
//   static const language = '/settings/language';
// }

// @riverpod
// GoRouter appRouter(AppRouterRef ref) {
//   final authState = ref.watch(authStateProvider);

//   return GoRouter(
//     initialLocation: AppRoutes.splash,
//     debugLogDiagnostics: true,
//     redirect: (context, state) {
//       final isAuthenticated = authState.valueOrNull != null;
//       final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
//           state.matchedLocation == AppRoutes.onboarding ||
//           state.matchedLocation == AppRoutes.splash;

//       if (!isAuthenticated && !isAuthRoute) {
//         return AppRoutes.onboarding;
//       }
//       if (isAuthenticated && isAuthRoute && state.matchedLocation != AppRoutes.splash) {
//         return AppRoutes.home;
//       }
//       return null;
//     },
//     routes: [
//       GoRoute(
//         path: AppRoutes.splash,
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.onboarding,
//         builder: (context, state) => const OnboardingScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.phoneAuth,
//         builder: (context, state) => const PhoneAuthScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.otpVerification,
//         builder: (context, state) {
//           final phone = state.extra as String? ?? '';
//           return OtpVerificationScreen(phoneNumber: phone);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.createPin,
//         builder: (context, state) => const CreatePinScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.biometricSetup,
//         builder: (context, state) => const BiometricSetupScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.kyc,
//         builder: (context, state) => const KycScreen(),
//       ),
//       ShellRoute(
//         builder: (context, state, child) => MainShell(child: child),
//         routes: [
//           GoRoute(
//             path: AppRoutes.home,
//             builder: (context, state) => const WalletScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.exchange,
//             builder: (context, state) => const CurrencyExchangeScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.history,
//             builder: (context, state) => const TransactionHistoryScreen(),
//           ),
//           GoRoute(
//             path: AppRoutes.settings,
//             builder: (context, state) => const SettingsScreen(),
//           ),
//         ],
//       ),
//       GoRoute(
//         path: AppRoutes.wallet,
//         builder: (context, state) => const WalletScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.sendMoney,
//         builder: (context, state) => const SendMoneyScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.receiveMoney,
//         builder: (context, state) => const ReceiveMoneyScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.confirmTransfer,
//         builder: (context, state) {
//           final data = state.extra as Map<String, dynamic>? ?? {};
//           return ConfirmTransferScreen(transferData: data);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.transferSuccess,
//         builder: (context, state) {
//           final data = state.extra as Map<String, dynamic>? ?? {};
//           return TransferSuccessScreen(transferData: data);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.crypto,
//         builder: (context, state) => const CryptoScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.cryptoBuy,
//         builder: (context, state) {
//           final data = state.extra as Map<String, dynamic>? ?? {};
//           return CryptoBuyScreen(cryptoData: data);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.virtualCard,
//         builder: (context, state) => const VirtualCardScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.transactionDetail,
//         builder: (context, state) {
//           final txId = state.extra as String? ?? '';
//           return TransactionDetailScreen(transactionId: txId);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.notifications,
//         builder: (context, state) => const NotificationsScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.profile,
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.security,
//         builder: (context, state) => const SecurityScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.language,
//         builder: (context, state) => const LanguageScreen(),
//       ),
//     ],
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Text('Page non trouvée: ${state.error}'),
//       ),
//     ),
//   );
// }

// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/home/dashboard_screen.dart';
import '../presentation/screens/wallet/wallet_screen.dart';
import '../presentation/screens/transfer/send_money_screen.dart';
import '../presentation/screens/exchange/exchange_screen.dart';
import '../presentation/screens/crypto/crypto_screen.dart';
import '../presentation/screens/history/history_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;
      if (isLoading) return null;

      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.matchedLocation == RouteNames.splash;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.otp;

      if (!isAuthenticated && !isAuthRoute && !isSplash) {
        return RouteNames.login;
      }
      if (isAuthenticated && isAuthRoute) {
        return RouteNames.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            phoneNumber: extra?['phone'] ?? '',
            verificationId: extra?['verificationId'] ?? '',
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.wallet,
            builder: (_, __) => const WalletScreen(),
          ),
          GoRoute(
            path: RouteNames.exchange,
            builder: (_, __) => const ExchangeScreen(),
          ),
          GoRoute(
            path: RouteNames.crypto,
            builder: (_, __) => const CryptoScreen(),
          ),
          GoRoute(
            path: RouteNames.history,
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.sendMoney,
        builder: (_, __) => const SendMoneyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page introuvable: ${state.error}'),
            TextButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ── Main Shell with Bottom Nav ─────────────────────────────────────────────
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(RouteNames.dashboard)) return 0;
    if (location.startsWith(RouteNames.exchange)) return 1;
    if (location.startsWith(RouteNames.crypto)) return 2;
    if (location.startsWith(RouteNames.history)) return 3;
    if (location.startsWith(RouteNames.settings)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _locationToIndex(location);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go(RouteNames.dashboard);
              break;
            case 1:
              context.go(RouteNames.exchange);
              break;
            case 2:
              context.go(RouteNames.crypto);
              break;
            case 3:
              context.go(RouteNames.history);
              break;
            case 4:
              context.go(RouteNames.settings);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            selectedIcon: Icon(Icons.currency_exchange),
            label: 'Change',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_bitcoin_outlined),
            selectedIcon: Icon(Icons.currency_bitcoin),
            label: 'Crypto',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
