import 'package:flutter/material.dart';

import 'package:simpleflow/src/common_widgets/category_icon.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/utils/icon_mapper.dart';
import 'package:simpleflow/src/data/models/models.dart';

/// Tuile affichant une catégorie avec actions.
class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    required this.category,
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.hasTransactions = false,
  });

  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Indique si la catégorie a des transactions liées.
  /// Si true, le bouton supprimer sera désactivé.
  final bool hasTransactions;

  void _showCannotDeleteMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Impossible de supprimer une catégorie liée à des transactions',
        ),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CategoryIcon.fromHex(
                icon: IconMapper.getIcon(category.iconKey),
                colorHex: category.color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.bodyLarge(color: textColor),
                    ),
                    if (category.isDefault) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Catégorie par défaut',
                        style: AppTextStyles.caption(color: subtitleColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (!category.isDefault) ...[
                if (onEdit != null)
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: subtitleColor,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Modifier',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: hasTransactions
                          ? subtitleColor.withValues(alpha: 0.4)
                          : AppColors.error,
                      size: 20,
                    ),
                    onPressed: hasTransactions
                        ? () => _showCannotDeleteMessage(context)
                        : onDelete,
                    tooltip: 'Supprimer',
                  ),
              ] else
                Icon(
                  Icons.lock_outline,
                  color: subtitleColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
