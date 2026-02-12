import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/features/stats/presentation/stats_state.dart';

/// Tuile affichant la progression d'un budget pour une catégorie.
///
/// Affiche :
/// - Icône de la catégorie
/// - Nom de la catégorie avec montant dépensé / limite
/// - Barre de progression colorée selon le statut
/// - Montant restant ou dépassement
class BudgetProgressTile extends StatelessWidget {
  const BudgetProgressTile({
    required this.budgetProgress,
    super.key,
    this.onTap,
  });

  /// Les données de progression du budget.
  final BudgetProgress budgetProgress;

  /// Callback appelé lors du tap sur la tuile.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final category = budgetProgress.category;
    final progressColor = _getProgressColor(budgetProgress.status);
    final percentage = (budgetProgress.percentageUsed * 100).clamp(0, 100).toInt();
    final progressValue = budgetProgress.percentageUsed.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Category icon
            CategoryIcon(
              icon: IconMapper.getIcon(category.iconKey),
              color: Color(category.color),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name and amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTextStyles.labelMedium(color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(budgetProgress.currentSpending)} / ${CurrencyFormatter.format(budgetProgress.budgetLimit)}',
                        style: AppTextStyles.bodySmall(color: secondaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: progressColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Remaining text and percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getRemainingText(budgetProgress),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne la couleur selon le statut du budget.
  Color _getProgressColor(BudgetStatus status) {
    return switch (status) {
      BudgetStatus.safe => AppColors.success,
      BudgetStatus.warning => AppColors.warning,
      BudgetStatus.exceeded => AppColors.error,
    };
  }

  /// Retourne le texte du montant restant ou dépassé.
  String _getRemainingText(BudgetProgress budget) {
    if (budget.isOverBudget) {
      return 'Dépassé de ${CurrencyFormatter.format(budget.remaining.abs())}';
    }
    return '${CurrencyFormatter.format(budget.remaining)} restant';
  }
}
