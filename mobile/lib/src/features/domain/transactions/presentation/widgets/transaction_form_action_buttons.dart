import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_state.dart';

/// Represents a secondary action button (e.g., delete, re-emit).
class TransactionFormAction {
  const TransactionFormAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isDestructive = false,
    this.showLoading = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final Color? color;
  final bool isDestructive;
  final bool showLoading;
}

class TransactionFormActionButtons extends StatelessWidget {
  const TransactionFormActionButtons({
    required this.state,
    required this.primaryLabel,
    required this.onPrimaryAction,
    required this.isDark,
    required this.bottomPadding,
    this.secondaryActions,
    super.key,
  });

  final TransactionFormState state;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;
  final List<TransactionFormAction>? secondaryActions;
  final bool isDark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isValid && !state.isBusy ? onPrimaryAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      style: AppTextStyles.button(color: Colors.white),
                    ),
            ),
          ),
          if (secondaryActions != null && secondaryActions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: secondaryActions!.map((action) {
                final color = action.color ??
                    (action.isDestructive ? AppColors.error : AppColors.success);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: action != secondaryActions!.last ? 12 : 0,
                    ),
                    child: OutlinedButton(
                      onPressed: !state.isBusy ? action.onPressed : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(
                          color: state.isBusy
                              ? (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.dividerLight)
                              : color,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: action.showLoading && state.isDeleting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: color,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(action.icon, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  action.label,
                                  style: AppTextStyles.button(color: color),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
