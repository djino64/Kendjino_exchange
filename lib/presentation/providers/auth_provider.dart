// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../injection/dependency_injection.dart';

// ── Auth State ─────────────────────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;
  final String? verificationId;
  final bool otpSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.verificationId,
    this.otpSent = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? error,
    String? verificationId,
    bool? otpSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      otpSent: otpSent ?? this.otpSent,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// ── Auth Notifier ──────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _ref.read(getCurrentUserUseCaseProvider).call();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _ref.read(sendOtpUseCaseProvider).call(phone);
      state = state.copyWith(
        status: AuthStatus.initial,
        otpSent: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<bool> verifyOtp(String verificationId, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user =
          await _ref.read(verifyOtpUseCaseProvider).call(verificationId, otp);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Code incorrect. Réessayez.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _ref.read(signOutUseCaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, status: AuthStatus.initial);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

// Convenience providers
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});