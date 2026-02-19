import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';

/// Affichage du montant du budget dans le formulaire de creation.
class CreateBudgetAmountDisplay extends StatelessWidget {
  const CreateBudgetAmountDisplay({
    required this.displayAmount,
    required this.amountCents,
    required this.showKeypad,
    required this.onTap,
    super.key,
  });

  final String displayAmount;
  final int amountCents;
  final bool showKeypad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final hintColor =
        isDark ? AppColors.textHintDark : AppColors.textHintLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: showKeypad
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showKeypad
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Limite mensuelle',
              style: AppTextStyles.labelMedium(color: secondaryColor),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey(displayAmount),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayAmount,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: amountCents == 0
                          ? textColor.withValues(alpha: 0.3)
                          : textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '€',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: amountCents == 0
                            ? textColor.withValues(alpha: 0.3)
                            : textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showKeypad ? 'Tapez pour fermer' : 'Tapez pour modifier',
              style: AppTextStyles.caption(color: hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
