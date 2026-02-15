import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_state.dart';

/// Barre de progression du budget.
class BudgetDetailProgressBar extends StatelessWidget {
  const BudgetDetailProgressBar({
    required this.progress,
    super.key,
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
