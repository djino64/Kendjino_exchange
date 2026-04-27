import 'package:equatable/equatable.dart';

// ─── User Entity ─────────────────────────────────────────────────────────────
class UserEntity extends Equatable {
  final String uid;
  final String phoneNumber;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final KycStatus kycStatus;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserPreferences preferences;
  final bool isActive;

  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.kycStatus = KycStatus.pending,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences = const UserPreferences(),
    this.isActive = true,
  });

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? avatarUrl,
    KycStatus? kycStatus,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    bool? isActive,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    phoneNumber,
    fullName,
    email,
    avatarUrl,
    kycStatus,
    createdAt,
    lastLoginAt,
    preferences,
    isActive,
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
