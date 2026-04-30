// lib/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    super.displayName,
    super.email,
    super.photoUrl,
    super.isVerified,
    super.preferredLanguage,
    super.hasBiometric,
    super.hasPin,
    super.walletId,
    super.kycStatus,
    required super.createdAt,
    super.lastLoginAt,

  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'],
      photoUrl: data['photoUrl'] ?? '',
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == (data['kycStatus'] ?? 'pending'),
        orElse: () => KycStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['lastLoginAt'] as dynamic).millisecondsSinceEpoch)
          : null,
      isVerified: data['isVerified'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'fr',
      hasBiometric: data['hasBiometric'] ?? false,
      hasPin: data['hasPin'] ?? false,
      walletId: data['walletId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'kycStatus': kycStatus.name,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isVerified': isVerified,
      'preferredLanguage': preferredLanguage,
      'hasBiometric': hasBiometric,
      'hasPin': hasPin,
      'walletId': walletId,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      phoneNumber: entity.phoneNumber,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      kycStatus: entity.kycStatus,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isVerified: entity.isVerified,
      preferredLanguage: entity.preferredLanguage,
      hasBiometric: entity.hasBiometric,
      hasPin: entity.hasPin,
      walletId: entity.walletId,
    );
  }

  static UserPreferences _prefsFromMap(Map<String, dynamic> map) {
    return UserPreferences(
      languageCode: map['languageCode'] ?? 'fr',
      biometricEnabled: map['biometricEnabled'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkMode: map['darkMode'] ?? false,
      defaultCurrency: map['defaultCurrency'] ?? 'HTG',
    );
  }
}