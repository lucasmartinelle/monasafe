import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/recurring_providers.dart';

/// Section d'informations dans les details de la recurrence.
class RecurringDetailInfoSection extends StatelessWidget {
  const RecurringDetailInfoSection({
    required this.recurring,
    required this.formEndDate,
    required this.formIsActive,
    required this.onSelectEndDate,
    required this.onClearEndDate,
    super.key,
  });

  final RecurringTransactionWithDetails recurring;
  final DateTime? formEndDate;
  final bool formIsActive;
  final VoidCallback onSelectEndDate;
  final VoidCallback onClearEndDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final rec = recurring.recurring;
    final nextDate = calculateNextRecurringDate(
      rec.copyWith(isActive: formIsActive),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Debut',
            value: DateFormat('d MMMM yyyy', 'fr_FR').format(rec.startDate),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Jour du mois',
            value: 'Le ${rec.originalDay}',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Prochaine occurrence',
            value: nextDate != null
                ? DateFormat('d MMMM yyyy', 'fr_FR').format(nextDate)
                : 'Aucune',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date de fin',
                style: AppTextStyles.bodySmall(color: secondaryColor),
              ),
              GestureDetector(
                onTap: onSelectEndDate,
                child: Row(
                  children: [
                    Text(
                      formEndDate != null
                          ? DateFormat('d MMM yyyy', 'fr_FR')
                              .format(formEndDate!)
                          : 'Non definie',
                      style: AppTextStyles.bodySmall(color: textColor),
                    ),
                    const SizedBox(width: 4),
                    if (formEndDate != null)
                      GestureDetector(
                        onTap: onClearEndDate,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: secondaryColor,
                        ),
                      )
                    else
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: secondaryColor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ligne d'information dans les details.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: secondaryColor),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall(color: textColor),
        ),
      ],
    );
  }
}
