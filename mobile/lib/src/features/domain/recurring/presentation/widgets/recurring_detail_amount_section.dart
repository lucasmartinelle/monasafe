import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';

/// Section d'affichage du montant cliquable.
class RecurringDetailAmountSection extends StatelessWidget {
  const RecurringDetailAmountSection({
    required this.displayAmount,
    required this.amountCents,
    required this.showKeypad,
    required this.onTap,
    required this.isDark,
    super.key,
  });

  final String displayAmount;
  final int amountCents;
  final bool showKeypad;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayAmount,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\u20AC',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                  ),
                ),
              ],
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
