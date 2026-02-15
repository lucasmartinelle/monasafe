// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteSuggestionsHash() => r'73a56e3c0a8dfbe98780d0d87c9813de52e09100';

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

/// Provider for note suggestions based on search query and transaction type.
///
/// Copied from [noteSuggestions].
@ProviderFor(noteSuggestions)
const noteSuggestionsProvider = NoteSuggestionsFamily();

/// Provider for note suggestions based on search query and transaction type.
///
/// Copied from [noteSuggestions].
class NoteSuggestionsFamily
    extends Family<AsyncValue<List<TransactionWithDetails>>> {
  /// Provider for note suggestions based on search query and transaction type.
  ///
  /// Copied from [noteSuggestions].
  const NoteSuggestionsFamily();

  /// Provider for note suggestions based on search query and transaction type.
  ///
  /// Copied from [noteSuggestions].
  NoteSuggestionsProvider call(String query, CategoryType type) {
    return NoteSuggestionsProvider(query, type);
  }

  @override
  NoteSuggestionsProvider getProviderOverride(
    covariant NoteSuggestionsProvider provider,
  ) {
    return call(provider.query, provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteSuggestionsProvider';
}

/// Provider for note suggestions based on search query and transaction type.
///
/// Copied from [noteSuggestions].
class NoteSuggestionsProvider
    extends AutoDisposeFutureProvider<List<TransactionWithDetails>> {
  /// Provider for note suggestions based on search query and transaction type.
  ///
  /// Copied from [noteSuggestions].
  NoteSuggestionsProvider(String query, CategoryType type)
    : this._internal(
        (ref) => noteSuggestions(ref as NoteSuggestionsRef, query, type),
        from: noteSuggestionsProvider,
        name: r'noteSuggestionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$noteSuggestionsHash,
        dependencies: NoteSuggestionsFamily._dependencies,
        allTransitiveDependencies:
            NoteSuggestionsFamily._allTransitiveDependencies,
        query: query,
        type: type,
      );

  NoteSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.type,
  }) : super.internal();

  final String query;
  final CategoryType type;

  @override
  Override overrideWith(
    FutureOr<List<TransactionWithDetails>> Function(NoteSuggestionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NoteSuggestionsProvider._internal(
        (ref) => create(ref as NoteSuggestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionWithDetails>>
  createElement() {
    return _NoteSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteSuggestionsProvider &&
        other.query == query &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteSuggestionsRef
    on AutoDisposeFutureProviderRef<List<TransactionWithDetails>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `type` of this provider.
  CategoryType get type;
}

class _NoteSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionWithDetails>>
    with NoteSuggestionsRef {
  _NoteSuggestionsProviderElement(super.provider);

  @override
  String get query => (origin as NoteSuggestionsProvider).query;
  @override
  CategoryType get type => (origin as NoteSuggestionsProvider).type;
}

String _$transactionFormNotifierHash() =>
    r'80565d0a888ce3f819c6fc87109d21d208c5c703';

/// Unified notifier for transaction forms (add/edit).
///
/// Copied from [TransactionFormNotifier].
@ProviderFor(TransactionFormNotifier)
final transactionFormNotifierProvider =
    NotifierProvider<TransactionFormNotifier, TransactionFormState>.internal(
      TransactionFormNotifier.new,
      name: r'transactionFormNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionFormNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionFormNotifier = Notifier<TransactionFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
