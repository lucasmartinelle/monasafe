// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentMonthExpensesStreamHash() =>
    r'6fb491b87997b114f63127f0e728500d34133bcd';

/// Stream of current month expenses grouped by category for the PieChart.
/// Filters by selected account if one is selected.
///
/// Copied from [currentMonthExpensesStream].
@ProviderFor(currentMonthExpensesStream)
final currentMonthExpensesStreamProvider =
    AutoDisposeStreamProvider<List<CategoryStatistics>>.internal(
      currentMonthExpensesStream,
      name: r'currentMonthExpensesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentMonthExpensesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMonthExpensesStreamRef =
    AutoDisposeStreamProviderRef<List<CategoryStatistics>>;
String _$filteredRecentTransactionsStreamHash() =>
    r'2ef264f98316447b11117224d95afd85886427bc';

/// Stream of recent transactions filtered by selected account.
///
/// Copied from [filteredRecentTransactionsStream].
@ProviderFor(filteredRecentTransactionsStream)
final filteredRecentTransactionsStreamProvider =
    AutoDisposeStreamProvider<List<TransactionWithDetails>>.internal(
      filteredRecentTransactionsStream,
      name: r'filteredRecentTransactionsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredRecentTransactionsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredRecentTransactionsStreamRef =
    AutoDisposeStreamProviderRef<List<TransactionWithDetails>>;
String _$selectedAccountIdHash() => r'7c913ce53cdd883170cb04aab423f4a609787402';

/// Provider for the currently selected account ID.
/// null means "All accounts".
///
/// Copied from [SelectedAccountId].
@ProviderFor(SelectedAccountId)
final selectedAccountIdProvider =
    AutoDisposeNotifierProvider<SelectedAccountId, String?>.internal(
      SelectedAccountId.new,
      name: r'selectedAccountIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedAccountIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedAccountId = AutoDisposeNotifier<String?>;
String _$paginatedTransactionsHash() =>
    r'266459a061f30ad649da098aa447e9469483ca57';

/// Notifier for paginated transactions with infinite scroll support.
///
/// Copied from [PaginatedTransactions].
@ProviderFor(PaginatedTransactions)
final paginatedTransactionsProvider =
    AutoDisposeNotifierProvider<
      PaginatedTransactions,
      PaginatedTransactionsState
    >.internal(
      PaginatedTransactions.new,
      name: r'paginatedTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paginatedTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PaginatedTransactions =
    AutoDisposeNotifier<PaginatedTransactionsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
