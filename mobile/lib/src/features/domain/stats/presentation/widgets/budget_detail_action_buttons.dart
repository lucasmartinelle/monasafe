import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';

/// Boutons d'action de la modal de detail du budget.
class BudgetDetailActionButtons extends StatelessWidget {
  const BudgetDetailActionButtons({
    required this.isValid,
    required this.isLoading,
    required this.isDeleting,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  final bool isValid;
  final bool isLoading;
  final bool isDeleting;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
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
              onPressed: isValid && !isLoading ? onUpdate : null,
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
              child: isLoading
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
              onPressed: !isDeleting ? onDelete : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: isDeleting
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
              child: isDeleting
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
    );
  }
}
