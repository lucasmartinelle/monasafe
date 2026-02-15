import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/stats/presentation/budget_form_provider.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_state.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/budget_detail_action_buttons.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/budget_detail_amount_section.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/budget_detail_header.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/budget_detail_progress_bar.dart';
import 'package:monasafe/src/features/domain/stats/presentation/widgets/budget_detail_transactions_list.dart';

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

            // Header
            BudgetDetailHeader(
              category: category,
              budgetProgress: widget.budgetProgress,
              onClose: () => Navigator.of(context).pop(),
            ),

            // Barre de progression
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BudgetDetailProgressBar(
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
                        style: AppTextStyles.labelMedium(
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      BudgetDetailAmountSection(
                        displayAmount:
                            formState?.displayAmount ?? '0,00',
                        amountCents: formState?.amountCents ?? 0,
                        showKeypad: _showKeypad,
                        onTap: _toggleKeypad,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Liste des transactions
                      BudgetDetailTransactionsList(
                        categoryId: category.id,
                        categoryColor: categoryColor,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Clavier numerique
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
            BudgetDetailActionButtons(
              isValid: formState?.isValid ?? false,
              isLoading: formState?.isLoading ?? false,
              isDeleting: formState?.isDeleting ?? false,
              onUpdate: _handleUpdate,
              onDelete: _handleDelete,
            ),
          ],
        ),
      ),
    );
  }
}
