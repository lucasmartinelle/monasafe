import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// Provider for the currently selected account ID.
/// null means "All accounts".
@riverpod
class SelectedAccountId extends _$SelectedAccountId {
  @override
  String? build() => null;

  void select(String? accountId) {
    state = accountId;
  }
}

/// Stream of current month expenses grouped by category for the PieChart.
/// Filters by selected account if one is selected.
/// Uses client-side calculations (amount is TEXT in DB).
@riverpod
Stream<List<CategoryStatistics>> currentMonthExpensesStream(Ref ref) {
  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  final selectedAccountId = ref.watch(selectedAccountIdProvider);
  final statisticsService = ref.watch(statisticsServiceProvider);
  final transactionService = ref.watch(transactionServiceProvider);

  // Utiliser watchAllTransactionsWithDetails et filtrer côté client
  return transactionService.watchAllTransactionsWithDetails().map((allTransactions) {
    // Calculer les dates du mois à chaque émission (pas au build du provider)
    final now = DateTime.now();
    final startOfMonth = DateTime.utc(now.year, now.month);
    final endOfMonth = DateTime.utc(now.year, now.month + 1).subtract(const Duration(milliseconds: 1));

    // Filtrer par période
    var transactions = allTransactions.where((tx) {
      final date = tx.transaction.date.toUtc();
      return !date.isBefore(startOfMonth) && !date.isAfter(endOfMonth);
    }).toList();

    // Filtrer par compte si sélectionné
    if (selectedAccountId != null) {
      transactions = transactions
          .where((tx) => tx.transaction.accountId == selectedAccountId)
          .toList();
    }

    // Calculer les stats par catégorie
    final stats = statisticsService.calculateCategoryStatsFromTransactions(transactions);

    // Ne garder que les dépenses
    return stats
        .where((s) => s.type == CategoryType.expense)
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  });
}

/// Stream of recent transactions filtered by selected account.
@riverpod
Stream<List<TransactionWithDetails>> filteredRecentTransactionsStream(Ref ref) {
  // Watch le trigger pour se rafraîchir après chaque transaction
  ref.watch(transactionsRefreshTriggerProvider);

  final repository = ref.watch(transactionRepositoryProvider);
  final selectedAccountId = ref.watch(selectedAccountIdProvider);

  if (selectedAccountId == null) {
    // All accounts
    return repository.watchRecentTransactions(10);
  } else {
    // Specific account - get recent transactions for this account
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 90));
    return repository
        .watchTransactionsByAccountAndPeriod(selectedAccountId, startDate, now)
        .map((transactions) {
      // Sort by date descending and take first 10
      transactions.sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );
      return transactions.take(10).toList();
    });
  }
}

/// State for paginated transactions
class PaginatedTransactionsState {

  const PaginatedTransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });
  final List<TransactionWithDetails> transactions;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  PaginatedTransactionsState copyWith({
    List<TransactionWithDetails>? transactions,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginatedTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Notifier for paginated transactions with infinite scroll support.
@riverpod
class PaginatedTransactions extends _$PaginatedTransactions {
  static const int _pageSize = 20;
  bool _isInitialized = false;

  @override
  PaginatedTransactionsState build() {
    // Watch account changes to reset and reload
    ref..watch(selectedAccountIdProvider)

    // Watch le trigger pour se rafraîchir après chaque transaction
    ..watch(transactionsRefreshTriggerProvider);

    // Reset when account changes
    _isInitialized = false;

    // Schedule initial load after build
    Future.microtask(() {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadInitial();
      }
    });

    return const PaginatedTransactionsState(isLoading: true);
  }

  Future<void> _loadInitial() async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final selectedAccountId = ref.read(selectedAccountIdProvider);

      final result = selectedAccountId == null
          ? await repository.getTransactionsPaginated(
              limit: _pageSize,
              offset: 0,
            )
          : await repository.getTransactionsByAccountPaginated(
              selectedAccountId,
              limit: _pageSize,
              offset: 0,
            );

      result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (newTransactions) {
          state = PaginatedTransactionsState(
            transactions: newTransactions,
            hasMore: newTransactions.length >= _pageSize,
            currentPage: 1,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final selectedAccountId = ref.read(selectedAccountIdProvider);
      final offset = state.currentPage * _pageSize;

      final result = selectedAccountId == null
          ? await repository.getTransactionsPaginated(
              limit: _pageSize,
              offset: offset,
            )
          : await repository.getTransactionsByAccountPaginated(
              selectedAccountId,
              limit: _pageSize,
              offset: offset,
            );

      result.fold(
        (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
        },
        (newTransactions) {
          state = state.copyWith(
            transactions: [...state.transactions, ...newTransactions],
            isLoading: false,
            hasMore: newTransactions.length >= _pageSize,
            currentPage: state.currentPage + 1,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  Future<void> refresh() async {
    _isInitialized = false;
    state = const PaginatedTransactionsState(isLoading: true);
    await _loadInitial();
  }
}
