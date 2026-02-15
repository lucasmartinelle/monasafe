import 'package:flutter/material.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';

/// Dialog pour supprimer toutes les donnees avec confirmation par texte.
class DeleteAllDataDialog extends StatefulWidget {
  const DeleteAllDataDialog({super.key});

  @override
  State<DeleteAllDataDialog> createState() => _DeleteAllDataDialogState();
}

class _DeleteAllDataDialogState extends State<DeleteAllDataDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canDelete = _controller.text == 'SUPPRIMER';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Supprimer toutes les données',
              style: AppTextStyles.h4(color: textColor),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action est irréversible. Toutes vos données seront définitivement supprimées :',
              style: AppTextStyles.bodyMedium(color: subtitleColor),
            ),
            const SizedBox(height: 12),
            Text('• Transactions',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Comptes',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Catégories personnalisées',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Budgets',
                style: AppTextStyles.bodySmall(color: textColor)),
            Text('• Récurrences',
                style: AppTextStyles.bodySmall(color: textColor)),
            const SizedBox(height: 16),
            Text(
              'Tapez SUPPRIMER pour confirmer :',
              style: AppTextStyles.bodySmall(color: subtitleColor),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _controller,
              hint: 'SUPPRIMER',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Annuler', style: TextStyle(color: textColor)),
        ),
        AppButton(
          label: 'Supprimer tout',
          onPressed: _canDelete ? () => Navigator.pop(context, true) : null,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
