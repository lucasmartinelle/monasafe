import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';

/// Item de categorie dans la grille de creation de budget.
class CreateBudgetCategoryItem extends StatelessWidget {
  const CreateBudgetCategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final categoryColor = Color(category.color);

    return SizedBox(
      width: 76,
      child: SelectableOptionContainer(
        isSelected: isSelected,
        onTap: onTap,
        selectedColor: categoryColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        enableHapticFeedback: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon.fromHex(
              icon: IconMapper.getIcon(category.iconKey),
              colorHex: category.color,
              size: CategoryIconSize.small,
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? textColor : subtitleColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
