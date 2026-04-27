// ─── Wallet Entity ────────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final Map<String, double> balances; // { 'HTG': 5000.0, 'USD': 37.5, ... }
  final DateTime lastUpdated;
  final String walletNumber;
 
  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balances,
    required this.lastUpdated,
    required this.walletNumber,
  });
 
  double getBalance(String currency) => balances[currency] ?? 0.0;
 
  WalletEntity copyWith({
    String? id,
    String? userId,
    Map<String, double>? balances,
    DateTime? lastUpdated,
    String? walletNumber,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balances: balances ?? this.balances,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      walletNumber: walletNumber ?? this.walletNumber,
    );
  }
 
  @override
  List<Object?> get props => [id, userId, balances, lastUpdated, walletNumber];
}