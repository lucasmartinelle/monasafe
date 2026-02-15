import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/transaction_form_provider.dart';

class TransactionFormDateSelector extends ConsumerWidget {
  const TransactionFormDateSelector({this.onInteraction, super.key});

  final VoidCallback? onInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(state.effectiveDate);

    return InkWell(
      onTap: () async {
        onInteraction?.call();
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: state.effectiveDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          final now = DateTime.now();
          final dateWithTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            now.hour,
            now.minute,
            now.second,
          );
          ref.read(transactionFormNotifierProvider.notifier).setDate(dateWithTime);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formattedDate,
                style: AppTextStyles.labelMedium(color: textColor),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }
}
