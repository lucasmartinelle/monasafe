// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurringWithDetailsHash() =>
    r'd6c5d362a304c41a23574fe80426c25488a16bb6';

/// Provider pour recuperer toutes les transactions recurrentes avec details.
///
/// Copied from [recurringWithDetails].
@ProviderFor(recurringWithDetails)
final recurringWithDetailsProvider =
    AutoDisposeFutureProvider<List<RecurringTransactionWithDetails>>.internal(
      recurringWithDetails,
      name: r'recurringWithDetailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recurringWithDetailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurringWithDetailsRef =
    AutoDisposeFutureProviderRef<List<RecurringTransactionWithDetails>>;
String _$activeRecurringWithDetailsHash() =>
    r'cb4b21835b5b5a411211d1073992a191efcfe64d';

/// Provider pour recuperer uniquement les recurrences actives avec details.
///
/// Copied from [activeRecurringWithDetails].
@ProviderFor(activeRecurringWithDetails)
final activeRecurringWithDetailsProvider =
    AutoDisposeFutureProvider<List<RecurringTransactionWithDetails>>.internal(
      activeRecurringWithDetails,
      name: r'activeRecurringWithDetailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeRecurringWithDetailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveRecurringWithDetailsRef =
    AutoDisposeFutureProviderRef<List<RecurringTransactionWithDetails>>;
String _$activeRecurringCountHash() =>
    r'28289c3c0845118331e7e38b0975a48b8bfc8221';

/// Provider pour compter le nombre de recurrences actives.
///
/// Copied from [activeRecurringCount].
@ProviderFor(activeRecurringCount)
final activeRecurringCountProvider = AutoDisposeFutureProvider<int>.internal(
  activeRecurringCount,
  name: r'activeRecurringCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeRecurringCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveRecurringCountRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
