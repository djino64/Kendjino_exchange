// lib/data/models/user_model.dart
import '../../domain/entities/entities.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.phoneNumber,
    super.displayName,
    super.email,
    super.photoUrl,
    required super.createdAt,
    super.isVerified,
    super.preferredLanguage,
    super.hasBiometric,
    super.hasPin,
    super.walletId,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'fr',
      hasBiometric: data['hasBiometric'] ?? false,
      hasPin: data['hasPin'] ?? false,
      walletId: data['walletId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
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
      createdAt: entity.createdAt,
      isVerified: entity.isVerified,
      preferredLanguage: entity.preferredLanguage,
      hasBiometric: entity.hasBiometric,
      hasPin: entity.hasPin,
      walletId: entity.walletId,
    );
  }
}