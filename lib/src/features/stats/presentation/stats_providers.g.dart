// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashflowDataStreamHash() =>
    r'34b59c39b5610da676e059cc0943338716f5c270';

/// Stream of cashflow data adapted to the selected period.
/// Returns monthly data for year view, daily data for month views.
/// Uses client-side calculations (amount is TEXT in DB).
///
/// Copied from [cashflowDataStream].
@ProviderFor(cashflowDataStream)
final cashflowDataStreamProvider =
    AutoDisposeStreamProvider<CashflowData>.internal(
      cashflowDataStream,
      name: r'cashflowDataStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashflowDataStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashflowDataStreamRef = AutoDisposeStreamProviderRef<CashflowData>;
String _$budgetProgressListHash() =>
    r'49ec62851926fcd08b67467a5fb3fbead9e58d14';

/// Future provider for budget progress list.
/// Combines user budgets with their spending for the selected period.
/// Uses client-side calculations (amount is TEXT in DB).
///
/// Copied from [budgetProgressList].
@ProviderFor(budgetProgressList)
final budgetProgressListProvider =
    AutoDisposeFutureProvider<List<BudgetProgress>>.internal(
      budgetProgressList,
      name: r'budgetProgressListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$budgetProgressListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetProgressListRef =
    AutoDisposeFutureProviderRef<List<BudgetProgress>>;
String _$budgetProgressStreamHash() =>
    r'a5cf9c1c836dc3915b7caa3ea7d16ecf20ff1251';

/// Stream version of budget progress for real-time updates.
/// Uses client-side calculations (amount is TEXT in DB).
///
/// Copied from [budgetProgressStream].
@ProviderFor(budgetProgressStream)
final budgetProgressStreamProvider =
    AutoDisposeStreamProvider<List<BudgetProgress>>.internal(
      budgetProgressStream,
      name: r'budgetProgressStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$budgetProgressStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BudgetProgressStreamRef =
    AutoDisposeStreamProviderRef<List<BudgetProgress>>;
String _$transactionsByCategoryHash() =>
    r'09b1e6a1ada29b66bd23c08403cd12e7c976d619';

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

/// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
///
/// Copied from [transactionsByCategory].
@ProviderFor(transactionsByCategory)
const transactionsByCategoryProvider = TransactionsByCategoryFamily();

/// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
///
/// Copied from [transactionsByCategory].
class TransactionsByCategoryFamily
    extends Family<AsyncValue<List<TransactionWithDetails>>> {
  /// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
  ///
  /// Copied from [transactionsByCategory].
  const TransactionsByCategoryFamily();

  /// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
  ///
  /// Copied from [transactionsByCategory].
  TransactionsByCategoryProvider call(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return TransactionsByCategoryProvider(categoryId, startDate, endDate);
  }

  @override
  TransactionsByCategoryProvider getProviderOverride(
    covariant TransactionsByCategoryProvider provider,
  ) {
    return call(provider.categoryId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsByCategoryProvider';
}

/// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
///
/// Copied from [transactionsByCategory].
class TransactionsByCategoryProvider
    extends AutoDisposeFutureProvider<List<TransactionWithDetails>> {
  /// Provider pour récupérer les transactions d'une catégorie pour une période donnée.
  ///
  /// Copied from [transactionsByCategory].
  TransactionsByCategoryProvider(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
        (ref) => transactionsByCategory(
          ref as TransactionsByCategoryRef,
          categoryId,
          startDate,
          endDate,
        ),
        from: transactionsByCategoryProvider,
        name: r'transactionsByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transactionsByCategoryHash,
        dependencies: TransactionsByCategoryFamily._dependencies,
        allTransitiveDependencies:
            TransactionsByCategoryFamily._allTransitiveDependencies,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );

  TransactionsByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String categoryId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<TransactionWithDetails>> Function(
      TransactionsByCategoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsByCategoryProvider._internal(
        (ref) => create(ref as TransactionsByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionWithDetails>>
  createElement() {
    return _TransactionsByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsByCategoryProvider &&
        other.categoryId == categoryId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionsByCategoryRef
    on AutoDisposeFutureProviderRef<List<TransactionWithDetails>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _TransactionsByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionWithDetails>>
    with TransactionsByCategoryRef {
  _TransactionsByCategoryProviderElement(super.provider);

  @override
  String get categoryId =>
      (origin as TransactionsByCategoryProvider).categoryId;
  @override
  DateTime get startDate =>
      (origin as TransactionsByCategoryProvider).startDate;
  @override
  DateTime get endDate => (origin as TransactionsByCategoryProvider).endDate;
}

String _$selectedPeriodHash() => r'45d1a0c49b8f20d94aed0a64474e46b1e29920c9';

/// Provider for the currently selected period.
/// Defaults to "This Month".
///
/// Copied from [SelectedPeriod].
@ProviderFor(SelectedPeriod)
final selectedPeriodProvider =
    AutoDisposeNotifierProvider<SelectedPeriod, PeriodType>.internal(
      SelectedPeriod.new,
      name: r'selectedPeriodProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedPeriodHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedPeriod = AutoDisposeNotifier<PeriodType>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
