import 'package:equatable/equatable.dart';

// ─── User Entity ─────────────────────────────────────────────────────────────
class UserEntity extends Equatable {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isVerified;
  final String preferredLanguage;
  final bool hasBiometric;
  final bool hasPin;
  final String? walletId;
  final KycStatus kycStatus;
  final DateTime? lastLoginAt;
  

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.createdAt,
    this.isVerified = false,
    this.preferredLanguage = 'fr',
    this.hasBiometric = false,
    this.hasPin = false,
    this.walletId,
    this.kycStatus = KycStatus.pending,
    this.lastLoginAt,
  });

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    bool? isVerified,
    String? preferredLanguage,
    bool? hasBiometric,
    bool? hasPin,
    String? walletId,
    KycStatus? kycStatus,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      hasBiometric: hasBiometric ?? this.hasBiometric,
      hasPin: hasPin ?? this.hasPin,
      walletId: walletId ?? this.walletId,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,

    );
  }

  @override
  List<Object?> get props => [
    uid,
    phoneNumber,
    displayName,
    email,
    photoUrl,
    createdAt,
    isVerified,
    preferredLanguage,
    hasBiometric,
    hasPin,
    walletId,
    kycStatus,
    lastLoginAt,

  ];
}

enum KycStatus { pending, submitted, verified, rejected }

class UserPreferences extends Equatable {
  final String languageCode;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool darkMode;
  final String defaultCurrency;

  const UserPreferences({
    this.languageCode = 'fr',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.defaultCurrency = 'HTG',
  });

  UserPreferences copyWith({
    String? languageCode,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? darkMode,
    String? defaultCurrency,
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    biometricEnabled,
    notificationsEnabled,
    darkMode,
    defaultCurrency,
  ];
}
