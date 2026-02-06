// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseClientHash() => r'2df5a38617329a3bb0a7e149189bea875722d7b8';

/// Provider pour le client Supabase
///
/// Copied from [supabaseClient].
@ProviderFor(supabaseClient)
final supabaseClientProvider = Provider<SupabaseClient>.internal(
  supabaseClient,
  name: r'supabaseClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseClientRef = ProviderRef<SupabaseClient>;
String _$authServiceHash() => r'684fe7f13fd9c55d75ec575ea7b9d40f6262c912';

/// Provider pour le service d'authentification
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = Provider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = ProviderRef<AuthService>;
String _$accountServiceHash() => r'9943eb08e24bb9a079ab8ad2317173833ed97217';

/// Provider pour le service des comptes
///
/// Copied from [accountService].
@ProviderFor(accountService)
final accountServiceProvider = Provider<AccountService>.internal(
  accountService,
  name: r'accountServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountServiceRef = ProviderRef<AccountService>;
String _$categoryServiceHash() => r'13e359a64654383b5dccf97eca8daf36c5426f76';

/// Provider pour le service des catégories
///
/// Copied from [categoryService].
@ProviderFor(categoryService)
final categoryServiceProvider = Provider<CategoryService>.internal(
  categoryService,
  name: r'categoryServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryServiceRef = ProviderRef<CategoryService>;
String _$transactionServiceHash() =>
    r'31575a1097b8c59274f17213dc81cbf714e26095';

/// Provider pour le service des transactions
/// Injecte automatiquement le VaultMiddleware si le vault est déverrouillé
///
/// Copied from [transactionService].
@ProviderFor(transactionService)
final transactionServiceProvider = Provider<TransactionService>.internal(
  transactionService,
  name: r'transactionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionServiceRef = ProviderRef<TransactionService>;
String _$statisticsServiceHash() => r'd81c23f2834b23c156ce5e248d3a2bdca6ac4786';

/// Provider pour le service des statistiques
///
/// Copied from [statisticsService].
@ProviderFor(statisticsService)
final statisticsServiceProvider = Provider<StatisticsService>.internal(
  statisticsService,
  name: r'statisticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statisticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatisticsServiceRef = ProviderRef<StatisticsService>;
String _$settingsServiceHash() => r'8acd7f9da1733ab8885213fb3bcf3d2c56733933';

/// Provider pour le service des paramètres
///
/// Copied from [settingsService].
@ProviderFor(settingsService)
final settingsServiceProvider = Provider<SettingsService>.internal(
  settingsService,
  name: r'settingsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsServiceRef = ProviderRef<SettingsService>;
String _$budgetServiceHash() => r'3b62d7e5b7ddb88cc84ef70c1d719dc392fa4537';

/// Provider pour le service des budgets
///
/// Copied from [budgetService].
@ProviderFor(budgetService)
final budgetServiceProvider = Provider<BudgetService>.internal(
  budgetService,
  name: r'budgetServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetServiceRef = ProviderRef<BudgetService>;
String _$pendingOnboardingServiceHash() =>
    r'c118180131a4b440b0facc631727d7b5f2b7c959';

/// Provider pour le service des données d'onboarding en attente (OAuth)
///
/// Copied from [pendingOnboardingService].
@ProviderFor(pendingOnboardingService)
final pendingOnboardingServiceProvider =
    Provider<PendingOnboardingService>.internal(
      pendingOnboardingService,
      name: r'pendingOnboardingServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingOnboardingServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOnboardingServiceRef = ProviderRef<PendingOnboardingService>;
String _$recurrenceDateServiceHash() =>
    r'93033cfc4581d1112c02d632851aa9579ca7ab4a';

/// Provider pour le service de calcul des dates de recurrence
///
/// Copied from [recurrenceDateService].
@ProviderFor(recurrenceDateService)
final recurrenceDateServiceProvider = Provider<RecurrenceDateService>.internal(
  recurrenceDateService,
  name: r'recurrenceDateServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurrenceDateServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurrenceDateServiceRef = ProviderRef<RecurrenceDateService>;
String _$recurringTransactionServiceHash() =>
    r'434ae6289055af1840e166b0e3f8b0f5dfe6293a';

/// Provider pour le service des transactions recurrentes
/// Injecte automatiquement le VaultMiddleware si le vault est deverrouille
///
/// Copied from [recurringTransactionService].
@ProviderFor(recurringTransactionService)
final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>.internal(
      recurringTransactionService,
      name: r'recurringTransactionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurringTransactionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurringTransactionServiceRef =
    ProviderRef<RecurringTransactionService>;
String _$recurrenceGeneratorServiceHash() =>
    r'c369981945ca7feb0bc225e81a0eecbfe6164acc';

/// Provider pour le service de generation des transactions recurrentes
///
/// Copied from [recurrenceGeneratorService].
@ProviderFor(recurrenceGeneratorService)
final recurrenceGeneratorServiceProvider =
    Provider<RecurrenceGeneratorService>.internal(
      recurrenceGeneratorService,
      name: r'recurrenceGeneratorServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurrenceGeneratorServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurrenceGeneratorServiceRef = ProviderRef<RecurrenceGeneratorService>;
String _$dataManagementServiceHash() =>
    r'167374076e5a183be5824e71f6b35b7e054905a0';

/// Provider pour le service de gestion des données (suppression)
///
/// Copied from [dataManagementService].
@ProviderFor(dataManagementService)
final dataManagementServiceProvider = Provider<DataManagementService>.internal(
  dataManagementService,
  name: r'dataManagementServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dataManagementServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DataManagementServiceRef = ProviderRef<DataManagementService>;
String _$accountRepositoryHash() => r'1c9849d93b8862cba52d2c333ec3d38bb2650022';

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
    r'2f43f0b32f6f7b9ad22ada0f86277441a613cd24';

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
    r'a981d1dac3f1a6fd3d6156183edc1b99f5eea6b6';

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
    r'566dbf8ec464800466e3e520114e977ee31e38f4';

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
String _$authStateStreamHash() => r'1acc24521b9c86483247d5f49239bba4368415c9';

/// Stream de l'état d'authentification
///
/// Copied from [authStateStream].
@ProviderFor(authStateStream)
final authStateStreamProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authStateStream,
  name: r'authStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateStreamRef = AutoDisposeStreamProviderRef<AuthState>;
String _$isAuthenticatedHash() => r'e88b4aca2cf8953acf242cda8a3342306a8072c3';

/// Provider pour vérifier si l'utilisateur est authentifié.
/// Écoute le stream d'auth pour être réactif aux changements.
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeStreamProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeStreamProviderRef<bool>;
String _$onboardingCompletedStreamHash() =>
    r'1d712b157d7d463eb5e75a47da9f693239183f09';

/// Stream de l'état de l'onboarding.
/// Retourne false si non authentifié, sinon écoute le setting onboarding_completed.
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
String _$accountsStreamHash() => r'70354fa0db210f7c158c6f18bc2c6a39f8dd7a14';

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
String _$categoriesStreamHash() => r'851e4932e07c099fc0a34e393936e63872efc550';

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
    r'3c80ea245147e37b9bb78e028ac617b69abcea65';

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
    r'cabfc7a44b3629dd53d388a439749b4c4cc466fc';

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
    r'3047e8f20cb1966ed89add36caeef6a4b9cdeed3';

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
    r'38123dae9318400748fe079affe6c9bd7ef5a2c3';

/// Stream du résumé financier
/// Utilise les calculs côté client pour supporter les colonnes TEXT.
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
    r'57d93ff0e2ab41d588ab83e0b007191d71cbf276';

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
/// Utilise le filtrage côté serveur pour de meilleures performances.
///
/// Copied from [accountCalculatedBalanceStream].
@ProviderFor(accountCalculatedBalanceStream)
const accountCalculatedBalanceStreamProvider =
    AccountCalculatedBalanceStreamFamily();

/// Stream du solde calculé d'un compte (solde initial + transactions)
/// Utilise le filtrage côté serveur pour de meilleures performances.
///
/// Copied from [accountCalculatedBalanceStream].
class AccountCalculatedBalanceStreamFamily extends Family<AsyncValue<double>> {
  /// Stream du solde calculé d'un compte (solde initial + transactions)
  /// Utilise le filtrage côté serveur pour de meilleures performances.
  ///
  /// Copied from [accountCalculatedBalanceStream].
  const AccountCalculatedBalanceStreamFamily();

  /// Stream du solde calculé d'un compte (solde initial + transactions)
  /// Utilise le filtrage côté serveur pour de meilleures performances.
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
/// Utilise le filtrage côté serveur pour de meilleures performances.
///
/// Copied from [accountCalculatedBalanceStream].
class AccountCalculatedBalanceStreamProvider
    extends AutoDisposeStreamProvider<double> {
  /// Stream du solde calculé d'un compte (solde initial + transactions)
  /// Utilise le filtrage côté serveur pour de meilleures performances.
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

String _$hasGoogleIdentityHash() => r'2e01cba58a9a840d8aee0b0cbe7cfd81fa69e40e';

/// Provider pour vérifier si l'utilisateur a un compte Google lié.
/// Fait un appel API pour récupérer les identities à jour.
///
/// Copied from [hasGoogleIdentity].
@ProviderFor(hasGoogleIdentity)
final hasGoogleIdentityProvider = AutoDisposeFutureProvider<bool>.internal(
  hasGoogleIdentity,
  name: r'hasGoogleIdentityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasGoogleIdentityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasGoogleIdentityRef = AutoDisposeFutureProviderRef<bool>;
String _$activeRecurringStreamHash() =>
    r'6d1e6e182cf47e7f271893bd20c131350db159a6';

/// Stream des transactions recurrentes actives
///
/// Copied from [activeRecurringStream].
@ProviderFor(activeRecurringStream)
final activeRecurringStreamProvider =
    AutoDisposeStreamProvider<List<RecurringTransaction>>.internal(
      activeRecurringStream,
      name: r'activeRecurringStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeRecurringStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveRecurringStreamRef =
    AutoDisposeStreamProviderRef<List<RecurringTransaction>>;
String _$generateRecurringTransactionsHash() =>
    r'9d2c64a36e8bfd372135fd8a68e4ce53a376af40';

/// Provider pour la generation des transactions recurrentes au demarrage.
/// Retourne le nombre de transactions generees.
///
/// Copied from [generateRecurringTransactions].
@ProviderFor(generateRecurringTransactions)
final generateRecurringTransactionsProvider =
    AutoDisposeFutureProvider<int>.internal(
      generateRecurringTransactions,
      name: r'generateRecurringTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generateRecurringTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GenerateRecurringTransactionsRef = AutoDisposeFutureProviderRef<int>;
String _$transactionsRefreshTriggerHash() =>
    r'd5a7d0279dc8c400186cb9a9e57aeb9635f99645';

/// Trigger de rafraîchissement pour les données liées aux transactions.
/// Incrémenté après chaque création/modification/suppression de transaction.
/// Les providers qui watchent ce trigger se recalculent automatiquement.
///
/// Copied from [TransactionsRefreshTrigger].
@ProviderFor(TransactionsRefreshTrigger)
final transactionsRefreshTriggerProvider =
    NotifierProvider<TransactionsRefreshTrigger, int>.internal(
      TransactionsRefreshTrigger.new,
      name: r'transactionsRefreshTriggerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionsRefreshTriggerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionsRefreshTrigger = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
