// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashflowDataStreamHash() =>
    r'e4f494c02c226b21ba6cf5ba6a34a61ac8fc3cc2';

/// Stream of cashflow data adapted to the selected period.
/// Returns monthly data for year view, daily data for month views.
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
    r'ee92c776bb0680000b35aca7c005a62e7243536f';

/// Future provider for budget progress list.
/// Combines user budgets with their spending for the selected period.
/// Note: budgetLimit is monthly, so we multiply by 12 for yearly view.
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
    r'4c3ad886d4a25418f757503d47666425456c6cd7';

/// Stream version of budget progress for real-time updates.
/// Note: budgetLimit is monthly, so we multiply by 12 for yearly view.
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
