import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/async_state_handler.dart';
import 'package:monasafe/src/common_widgets/glass_card.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/dashboard/presentation/dashboard_providers.dart';
import 'package:monasafe/src/features/dashboard/presentation/widgets/transaction_tile.dart';
import 'package:monasafe/src/features/transactions/presentation/screens/edit_transaction_screen.dart';

/// Card displaying recent transactions with infinite scroll.
class RecentTransactionsCard extends ConsumerStatefulWidget {
  const RecentTransactionsCard({super.key});

  @override
  ConsumerState<RecentTransactionsCard> createState() =>
      _RecentTransactionsCardState();
}

class _RecentTransactionsCardState
    extends ConsumerState<RecentTransactionsCard> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedTransactionsProvider.notifier).loadMore();
    }
  }

  Future<void> _onTransactionTap(TransactionWithDetails transaction) async {
    final result = await EditTransactionScreen.show(context, transaction);

    if (result != null && mounted) {
      // Refresh the list after any action
      ref.read(paginatedTransactionsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final paginatedState = ref.watch(paginatedTransactionsProvider);

    return GlassCardWithHeader(
      header: Text(
        'Transactions récentes',
        style: AppTextStyles.h4(color: textColor),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: _buildContent(paginatedState),
    );
  }

  Widget _buildContent(PaginatedTransactionsState state) {
    if (state.transactions.isEmpty && state.isLoading) {
      return const LoadingStateWidget();
    }

    if (state.transactions.isEmpty && state.error != null) {
      return ErrorStateWidget(
        message: 'Erreur de chargement',
        onRetry: () => ref.read(paginatedTransactionsProvider.notifier).refresh(),
      );
    }

    if (state.transactions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        message: 'Aucune transaction',
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.transactions.length) {
            return const LoadingStateWidget(
              padding: EdgeInsets.symmetric(vertical: 16),
              size: 20,
            );
          }
          final transaction = state.transactions[index];
          return TransactionTile(
            transaction: transaction,
            onTap: () => _onTransactionTap(transaction),
          );
        },
      ),
    );
  }
}
