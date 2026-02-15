import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/numeric_keypad.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/account_form_provider.dart';

/// Section du montant avec affichage et clavier numerique.
class AddAccountAmountSection extends ConsumerWidget {
  const AddAccountAmountSection({
    required this.isDark,
    super.key,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountFormNotifierProvider);
    final notifier = ref.read(accountFormNotifierProvider.notifier);
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        Text(
          'Solde initial',
          style: AppTextStyles.labelMedium(color: subtitleColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              state.displayAmount,
              style: AppTextStyles.h1(color: textColor),
            ),
            const SizedBox(width: 8),
            Text(
              '€',
              style: AppTextStyles.h2(color: subtitleColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        NumericKeypad(
          onDigit: notifier.appendDigit,
          onDelete: notifier.deleteDigit,
          onClear: notifier.clearAmount,
        ),
      ],
    );
  }
}
