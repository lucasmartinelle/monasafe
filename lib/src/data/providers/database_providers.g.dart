// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// Provider singleton pour la base de données
///
/// Utilise keepAlive pour maintenir l'instance en vie durant toute
/// la durée de l'application
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$accountRepositoryHash() => r'7f03ca567259c321e513b3af9f6ef8ceb5c700ce';

/// Provider pour le repository des comptes
///
/// Copied from [accountRepository].
@ProviderFor(accountRepository)
final accountRepositoryProvider = Provider<AccountRepository>.internal(
  accountRepository,
  name: r'accountRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountRepositoryRef = ProviderRef<AccountRepository>;
String _$categoryRepositoryHash() =>
    r'42c6ab4c980b47a5a35ee196ece32f45ed2478aa';

/// Provider pour le repository des catégories
///
/// Copied from [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider = Provider<CategoryRepository>.internal(
  categoryRepository,
  name: r'categoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = ProviderRef<CategoryRepository>;
String _$transactionRepositoryHash() =>
    r'06cf04f85e83dc88ef5bc426dd005e5599d85c50';

/// Provider pour le repository des transactions
///
/// Copied from [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider = Provider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef = ProviderRef<TransactionRepository>;
String _$settingsRepositoryHash() =>
    r'e31ef047767d19f0f35e396bb632aeaa345c272c';

/// Provider pour le repository des paramètres
///
/// Copied from [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = ProviderRef<SettingsRepository>;
String _$onboardingCompletedStreamHash() =>
    r'b168a9ef32385cdfa22282b06163dcee3979831a';

/// Stream de l'état de l'onboarding
///
/// Copied from [onboardingCompletedStream].
@ProviderFor(onboardingCompletedStream)
final onboardingCompletedStreamProvider =
    AutoDisposeStreamProvider<bool>.internal(
      onboardingCompletedStream,
      name: r'onboardingCompletedStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingCompletedStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingCompletedStreamRef = AutoDisposeStreamProviderRef<bool>;
String _$accountsStreamHash() => r'8b36923114d9a6dfb0513bfc1ff528b2186810be';

/// Stream de tous les comptes
///
/// Copied from [accountsStream].
@ProviderFor(accountsStream)
final accountsStreamProvider =
    AutoDisposeStreamProvider<List<Account>>.internal(
      accountsStream,
      name: r'accountsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$accountsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountsStreamRef = AutoDisposeStreamProviderRef<List<Account>>;
String _$categoriesStreamHash() => r'db36b68285d3ca90fbaca0f08c3b9db2b1f4809f';

/// Stream de toutes les catégories
///
/// Copied from [categoriesStream].
@ProviderFor(categoriesStream)
final categoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
      categoriesStream,
      name: r'categoriesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesStreamRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$expenseCategoriesStreamHash() =>
    r'a5fa49c6980e872309a18c1197df7f62edccbba3';

/// Stream des catégories de dépenses
///
/// Copied from [expenseCategoriesStream].
@ProviderFor(expenseCategoriesStream)
final expenseCategoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
      expenseCategoriesStream,
      name: r'expenseCategoriesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseCategoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseCategoriesStreamRef =
    AutoDisposeStreamProviderRef<List<Category>>;
String _$incomeCategoriesStreamHash() =>
    r'd17b2ea58a8d8f7b32c8edf0590ba1ededfa6944';

/// Stream des catégories de revenus
///
/// Copied from [incomeCategoriesStream].
@ProviderFor(incomeCategoriesStream)
final incomeCategoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
      incomeCategoriesStream,
      name: r'incomeCategoriesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$incomeCategoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IncomeCategoriesStreamRef =
    AutoDisposeStreamProviderRef<List<Category>>;
String _$recentTransactionsStreamHash() =>
    r'4c8221988eb758196b985828885bc04cbb266648';

/// Stream des transactions récentes (10 dernières)
///
/// Copied from [recentTransactionsStream].
@ProviderFor(recentTransactionsStream)
final recentTransactionsStreamProvider =
    AutoDisposeStreamProvider<List<TransactionWithDetails>>.internal(
      recentTransactionsStream,
      name: r'recentTransactionsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentTransactionsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentTransactionsStreamRef =
    AutoDisposeStreamProviderRef<List<TransactionWithDetails>>;
String _$financialSummaryStreamHash() =>
    r'379f7fb525323137e2d95d3af57ab5235f61dc2e';

/// Stream du résumé financier
///
/// Copied from [financialSummaryStream].
@ProviderFor(financialSummaryStream)
final financialSummaryStreamProvider =
    AutoDisposeStreamProvider<FinancialSummary>.internal(
      financialSummaryStream,
      name: r'financialSummaryStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$financialSummaryStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FinancialSummaryStreamRef =
    AutoDisposeStreamProviderRef<FinancialSummary>;
String _$accountCalculatedBalanceStreamHash() =>
    r'19343e624e350eb21c204edd5571a1fa53d99445';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Stream du solde calculé d'un compte (solde initial + transactions)
///
/// Copied from [accountCalculatedBalanceStream].
@ProviderFor(accountCalculatedBalanceStream)
const accountCalculatedBalanceStreamProvider =
    AccountCalculatedBalanceStreamFamily();

/// Stream du solde calculé d'un compte (solde initial + transactions)
///
/// Copied from [accountCalculatedBalanceStream].
class AccountCalculatedBalanceStreamFamily extends Family<AsyncValue<double>> {
  /// Stream du solde calculé d'un compte (solde initial + transactions)
  ///
  /// Copied from [accountCalculatedBalanceStream].
  const AccountCalculatedBalanceStreamFamily();

  /// Stream du solde calculé d'un compte (solde initial + transactions)
  ///
  /// Copied from [accountCalculatedBalanceStream].
  AccountCalculatedBalanceStreamProvider call(String accountId) {
    return AccountCalculatedBalanceStreamProvider(accountId);
  }

  @override
  AccountCalculatedBalanceStreamProvider getProviderOverride(
    covariant AccountCalculatedBalanceStreamProvider provider,
  ) {
    return call(provider.accountId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountCalculatedBalanceStreamProvider';
}

/// Stream du solde calculé d'un compte (solde initial + transactions)
///
/// Copied from [accountCalculatedBalanceStream].
class AccountCalculatedBalanceStreamProvider
    extends AutoDisposeStreamProvider<double> {
  /// Stream du solde calculé d'un compte (solde initial + transactions)
  ///
  /// Copied from [accountCalculatedBalanceStream].
  AccountCalculatedBalanceStreamProvider(String accountId)
    : this._internal(
        (ref) => accountCalculatedBalanceStream(
          ref as AccountCalculatedBalanceStreamRef,
          accountId,
        ),
        from: accountCalculatedBalanceStreamProvider,
        name: r'accountCalculatedBalanceStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$accountCalculatedBalanceStreamHash,
        dependencies: AccountCalculatedBalanceStreamFamily._dependencies,
        allTransitiveDependencies:
            AccountCalculatedBalanceStreamFamily._allTransitiveDependencies,
        accountId: accountId,
      );

  AccountCalculatedBalanceStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountId,
  }) : super.internal();

  final String accountId;

  @override
  Override overrideWith(
    Stream<double> Function(AccountCalculatedBalanceStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountCalculatedBalanceStreamProvider._internal(
        (ref) => create(ref as AccountCalculatedBalanceStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountId: accountId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<double> createElement() {
    return _AccountCalculatedBalanceStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountCalculatedBalanceStreamProvider &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountCalculatedBalanceStreamRef
    on AutoDisposeStreamProviderRef<double> {
  /// The parameter `accountId` of this provider.
  String get accountId;
}

class _AccountCalculatedBalanceStreamProviderElement
    extends AutoDisposeStreamProviderElement<double>
    with AccountCalculatedBalanceStreamRef {
  _AccountCalculatedBalanceStreamProviderElement(super.provider);

  @override
  String get accountId =>
      (origin as AccountCalculatedBalanceStreamProvider).accountId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
