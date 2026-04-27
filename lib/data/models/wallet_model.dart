// lib/data/models/wallet_model.dart
import '../../domain/entities/entities.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.htgBalance,
    required super.usdBalance,
    required super.walletNumber,
    required super.createdAt,
    super.usdtBalance,
    super.btcBalance,
  });

  factory WalletModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WalletModel(
      id: id,
      userId: data['userId'] ?? '',
      htgBalance: (data['htgBalance'] as num?)?.toDouble() ?? 0.0,
      usdBalance: (data['usdBalance'] as num?)?.toDouble() ?? 0.0,
      walletNumber: data['walletNumber'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
      usdtBalance: (data['usdtBalance'] as num?)?.toDouble() ?? 0.0,
      btcBalance: (data['btcBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'htgBalance': htgBalance,
      'usdBalance': usdBalance,
      'walletNumber': walletNumber,
      'createdAt': createdAt,
      'usdtBalance': usdtBalance,
      'btcBalance': btcBalance,
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      userId: entity.userId,
      htgBalance: entity.htgBalance,
      usdBalance: entity.usdBalance,
      walletNumber: entity.walletNumber,
      createdAt: entity.createdAt,
      usdtBalance: entity.usdtBalance,
      btcBalance: entity.btcBalance,
    );
  }
}