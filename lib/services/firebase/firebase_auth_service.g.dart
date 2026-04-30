// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthServiceHash() =>
    r'f243870dfb72e3121fd2fac740655aa1bbad3fbe';

/// See also [firebaseAuthService].
@ProviderFor(firebaseAuthService)
final firebaseAuthServiceProvider =
    AutoDisposeProvider<FirebaseAuthService>.internal(
  firebaseAuthService,
  name: r'firebaseAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseAuthServiceRef = AutoDisposeProviderRef<FirebaseAuthService>;
String _$authStateHash() => r'd8eb17123e8971f9b8086bb415a4b2bde52779e2';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
