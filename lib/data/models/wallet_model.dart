// lib/data/models/wallet_model.dart
import '../../domain/entities/entities.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balances,
    required super.lastUpdated,
    required super.walletNumber,
  });

  factory WalletModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WalletModel(
      id: id,
      userId: data['userId'] ?? '',
      balances:
          (data['balances'] as Map<String, dynamic>?)?.cast<String, double>() ??
              {},
      walletNumber: data['walletNumber'] ?? '',
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastUpdated'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'balances': balances,
      'lastUpdated': lastUpdated,
      'walletNumber': walletNumber,
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      userId: entity.userId,
      balances: entity.balances,
      walletNumber: entity.walletNumber,
      lastUpdated: entity.lastUpdated,
    );
  }
}
