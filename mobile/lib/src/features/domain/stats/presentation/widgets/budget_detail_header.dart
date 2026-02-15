import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/features/domain/stats/presentation/stats_state.dart';

/// Header de la modal de detail du budget.
class BudgetDetailHeader extends StatelessWidget {
  const BudgetDetailHeader({
    required this.category,
    required this.budgetProgress,
    required this.onClose,
    super.key,
  });

  final Category category;
  final BudgetProgress budgetProgress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
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
                  '${CurrencyFormatter.format(budgetProgress.currentSpending)} depenses sur ${CurrencyFormatter.format(budgetProgress.budgetLimit)}',
                  style: AppTextStyles.bodySmall(color: secondaryColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: secondaryColor),
          ),
        ],
      ),
    );
  }
}
