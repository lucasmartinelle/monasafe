import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/features/domain/stats/presentation/budget_form_provider.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_providers.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_state.dart';

/// Resultat de l'action effectuee dans la modal.
enum BudgetDetailResult { updated, deleted }

/// Modal pour afficher les details d'un budget, le modifier ou le supprimer.
class BudgetDetailModal extends ConsumerStatefulWidget {
  const BudgetDetailModal({
    required this.budgetProgress,
    super.key,
  });

  /// Les donnees de progression du budget.
  final BudgetProgress budgetProgress;

  /// Affiche la modal de detail du budget.
  static Future<BudgetDetailResult?> show(
    BuildContext context,
    BudgetProgress budgetProgress,
  ) {
    return showModalBottomSheet<BudgetDetailResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetDetailModal(budgetProgress: budgetProgress),
    );
  }

  @override
  ConsumerState<BudgetDetailModal> createState() => _BudgetDetailModalState();
}

class _BudgetDetailModalState extends ConsumerState<BudgetDetailModal> {
  bool _showKeypad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(budgetFormNotifierProvider.notifier)
          .loadFromBudgetProgress(widget.budgetProgress);
    });
  }

  void _toggleKeypad() {
    setState(() {
      _showKeypad = !_showKeypad;
    });
  }

  void _hideKeypad() {
    if (_showKeypad) {
      setState(() {
        _showKeypad = false;
      });
    }
  }

  Future<void> _handleUpdate() async {
    final success =
        await ref.read(budgetFormNotifierProvider.notifier).update();
    if (success && mounted) {
      Navigator.of(context).pop(BudgetDetailResult.updated);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le budget'),
        content: Text(
          'Voulez-vous vraiment supprimer le budget pour "${widget.budgetProgress.category.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success =
          await ref.read(budgetFormNotifierProvider.notifier).delete();
      if (success && mounted) {
        Navigator.of(context).pop(BudgetDetailResult.deleted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final formState = ref.watch(budgetFormNotifierProvider);
    final category = widget.budgetProgress.category;
    final categoryColor = Color(category.color);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header avec categorie
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 16),
              child: Row(
                children: [
                  CategoryIcon.fromHex(
                    icon: IconMapper.getIcon(category.iconKey),
                    colorHex: category.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: AppTextStyles.h4(color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyFormatter.format(widget.budgetProgress.currentSpending)} depenses sur ${CurrencyFormatter.format(widget.budgetProgress.budgetLimit)}',
                          style: AppTextStyles.bodySmall(color: secondaryColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: secondaryColor),
                  ),
                ],
              ),
            ),

            // Barre de progression
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _BudgetProgressBar(
                progress: widget.budgetProgress,
              ),
            ),

            const SizedBox(height: 16),

            // Contenu scrollable
            Flexible(
              child: GestureDetector(
                onTap: _hideKeypad,
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section modification du montant
                      Text(
                        'Budget mensuel',
                        style: AppTextStyles.labelMedium(color: secondaryColor),
                      ),
                      const SizedBox(height: 12),

                      // Affichage du montant cliquable
                      _AmountSection(
                        displayAmount: formState?.displayAmount ?? '0,00',
                        amountCents: formState?.amountCents ?? 0,
                        showKeypad: _showKeypad,
                        onTap: _toggleKeypad,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Liste des transactions
                      _BudgetTransactionsList(
                        categoryId: category.id,
                        categoryColor: categoryColor,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Clavier numerique (toggle)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showKeypad
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: NumericKeypad(
                        onDigit: ref
                            .read(budgetFormNotifierProvider.notifier)
                            .appendDigit,
                        onDelete: ref
                            .read(budgetFormNotifierProvider.notifier)
                            .deleteDigit,
                        onClear: ref
                            .read(budgetFormNotifierProvider.notifier)
                            .clearAmount,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Boutons d'action
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12 + mediaQuery.padding.bottom,
              ),
              child: Column(
                children: [
                  // Bouton principal Modifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (formState?.isValid ?? false) &&
                              formState?.isLoading != true
                          ? _handleUpdate
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.dividerLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState?.isLoading ?? false
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Modifier le budget',
                              style: AppTextStyles.button(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bouton Supprimer
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: formState?.isDeleting != true
                          ? _handleDelete
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: formState?.isDeleting ?? false
                              ? (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight)
                              : AppColors.error,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: formState?.isDeleting ?? false
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_outline, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Supprimer',
                                  style:
                                      AppTextStyles.button(color: AppColors.error),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section d'affichage du montant cliquable.
class _AmountSection extends StatelessWidget {
  const _AmountSection({
    required this.displayAmount,
    required this.amountCents,
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
  });

  final String displayAmount;
  final int amountCents;
  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor =
        isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: showKeypad
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showKeypad
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayAmount,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\u20AC',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              showKeypad ? 'Tapez pour fermer' : 'Tapez pour modifier',
              style: AppTextStyles.caption(color: hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre de progression du budget.
class _BudgetProgressBar extends StatelessWidget {
  const _BudgetProgressBar({
    required this.progress,
  });

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final percentage = (progress.percentageUsed * 100).clamp(0, 100).toInt();
    final progressValue = progress.percentageUsed.clamp(0.0, 1.0);
    final progressColor = _getProgressColor(progress.status);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: progressColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getRemainingText(progress),
              style: AppTextStyles.caption(color: progressColor).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: AppTextStyles.caption(color: secondaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(BudgetStatus status) {
    return switch (status) {
      BudgetStatus.safe => AppColors.success,
      BudgetStatus.warning => AppColors.warning,
      BudgetStatus.exceeded => AppColors.error,
    };
  }

  String _getRemainingText(BudgetProgress budget) {
    if (budget.isOverBudget) {
      return 'Depasse de ${CurrencyFormatter.format(budget.remaining.abs())}';
    }
    return '${CurrencyFormatter.format(budget.remaining)} restant';
  }
}

/// Liste des transactions pour la categorie du budget.
class _BudgetTransactionsList extends ConsumerWidget {
  const _BudgetTransactionsList({
    required this.categoryId,
    required this.categoryColor,
  });

  final String categoryId;
  final Color categoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final period = ref.watch(selectedPeriodProvider);
    final (startDate, endDate) = period.dateRange;

    final transactionsAsync = ref.watch(
      transactionsByCategoryProvider(categoryId, startDate, endDate),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(color: secondaryColor.withValues(alpha: 0.2)),
        const SizedBox(height: 12),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions ${period.label.toLowerCase()}',
              style: AppTextStyles.labelMedium(color: textColor),
            ),
            if (transactionsAsync.hasValue)
              Text(
                '${transactionsAsync.value!.length}',
                style: AppTextStyles.caption(color: secondaryColor),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Liste des transactions
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: secondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune transaction',
                        style: AppTextStyles.bodySmall(color: secondaryColor),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Limiter a 10 transactions max
            final displayedTransactions = transactions.take(10).toList();
            final hasMore = transactions.length > 10;

            return Column(
              children: [
                ...displayedTransactions.map(
                  (tx) => TransactionTile(transaction: tx),
                ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${transactions.length - 10} autres transactions',
                      style: AppTextStyles.caption(color: secondaryColor),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingStateWidget(
              message: 'Chargement...',
              padding: EdgeInsets.zero,
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ErrorStateWidget(
              message: 'Erreur: $error',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
