import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';

/// Header de la modal de detail de la recurrence.
class RecurringDetailHeader extends StatelessWidget {
  const RecurringDetailHeader({
    required this.category,
    required this.accountName,
    required this.isActive,
    required this.onClose,
    super.key,
  });

  final Category? category;
  final String accountName;
  final bool isActive;
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
          if (category != null)
            CategoryIcon.fromHex(
              icon: IconMapper.getIcon(category!.iconKey),
              colorHex: category!.color,
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.help_outline,
                color: secondaryColor,
                size: 22,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.name ?? 'Categorie supprimee',
                  style: AppTextStyles.h4(color: textColor),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      accountName,
                      style: AppTextStyles.bodySmall(color: secondaryColor),
                    ),
                    if (!isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Inactive',
                          style: AppTextStyles.caption(
                            color: AppColors.warning,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ],
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
