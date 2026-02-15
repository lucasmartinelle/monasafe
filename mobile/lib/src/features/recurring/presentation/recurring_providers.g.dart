// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurringWithDetailsHash() =>
    r'de63ae021a97db5cee8d24319695b4239613658c';

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
    r'0d0efe8007fdf5f1c12f4a3e33d26553346d3764';

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
