// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$encryptionServiceHash() => r'1b145ebc4d0ae37af8c73a4ac06b8fa976b2b0c9';

/// See also [encryptionService].
@ProviderFor(encryptionService)
final encryptionServiceProvider = Provider<EncryptionService>.internal(
  encryptionService,
  name: r'encryptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$encryptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EncryptionServiceRef = ProviderRef<EncryptionService>;
String _$secureStorageHash() => r'a258bda40d2f36685fbecdd5f830905be2798ff2';

/// See also [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<FlutterSecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<FlutterSecureStorage>;
String _$localAuthHash() => r'352b04d375edb7326ce1ca3fb7835db923b866eb';

/// See also [localAuth].
@ProviderFor(localAuth)
final localAuthProvider = Provider<LocalAuthentication>.internal(
  localAuth,
  name: r'localAuthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalAuthRef = ProviderRef<LocalAuthentication>;
String _$isVaultReadyHash() => r'3757d2eec2fae7f927d7fb5696383c3f2ef21d6e';

/// Provider pour savoir si le vault est déverrouillé et prêt pour le chiffrement.
///
/// Copied from [isVaultReady].
@ProviderFor(isVaultReady)
final isVaultReadyProvider = AutoDisposeProvider<bool>.internal(
  isVaultReady,
  name: r'isVaultReadyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isVaultReadyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsVaultReadyRef = AutoDisposeProviderRef<bool>;
String _$currentDekHash() => r'0f9dc6a8586d0c84dea75dab7361fb21554a9a46';

/// Provider pour obtenir la DEK si disponible.
///
/// Copied from [currentDek].
@ProviderFor(currentDek)
final currentDekProvider = AutoDisposeProvider<Uint8List?>.internal(
  currentDek,
  name: r'currentDekProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentDekHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentDekRef = AutoDisposeProviderRef<Uint8List?>;
String _$dekInMemoryHash() => r'72e002c8be918f7c2352e6d1eecffd1cc42c5481';

/// DEK (Data Encryption Key) en mémoire, disponible uniquement quand le vault est déverrouillé.
///
/// Copied from [DekInMemory].
@ProviderFor(DekInMemory)
final dekInMemoryProvider = NotifierProvider<DekInMemory, Uint8List?>.internal(
  DekInMemory.new,
  name: r'dekInMemoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dekInMemoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DekInMemory = Notifier<Uint8List?>;
String _$vaultNotifierHash() => r'f8e908056f054726ddcca6639e4ca405aa20d943';

/// See also [VaultNotifier].
@ProviderFor(VaultNotifier)
final vaultNotifierProvider =
    NotifierProvider<VaultNotifier, VaultState>.internal(
      VaultNotifier.new,
      name: r'vaultNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vaultNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VaultNotifier = Notifier<VaultState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
