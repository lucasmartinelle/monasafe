import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';

/// Dialog de confirmation generique pour la suppression de donnees.
class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(title, style: AppTextStyles.h4(color: textColor)),
      content:
          Text(message, style: AppTextStyles.bodyMedium(color: subtitleColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler', style: TextStyle(color: textColor)),
        ),
        AppButton(
          label: 'Supprimer',
          onPressed: () => Navigator.pop(context, true),
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
