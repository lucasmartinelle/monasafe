import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/features/transactions/presentation/transaction_form_provider.dart';

/// Displays the current amount being entered with animation.
class AmountDisplay extends ConsumerWidget {
  const AmountDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = state.type == CategoryType.expense
        ? AppColors.error
        : AppColors.success;

    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Type indicator
        Text(
          state.type == CategoryType.expense ? 'Dépense' : 'Revenu',
          style: AppTextStyles.labelMedium(color: color),
        ),
        const SizedBox(height: 8),
        // Amount
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
            key: ValueKey(state.displayAmount),
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.displayAmount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: state.amountCents == 0
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
                    color: state.amountCents == 0
                        ? textColor.withValues(alpha: 0.3)
                        : textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
