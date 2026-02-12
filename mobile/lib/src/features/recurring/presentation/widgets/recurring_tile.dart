import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/recurring/presentation/recurring_providers.dart';

/// Tuile affichant une transaction recurrente dans la liste.
class RecurringTile extends StatelessWidget {
  const RecurringTile({
    required this.recurring,
    this.onTap,
    super.key,
  });

  final RecurringTransactionWithDetails recurring;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final disabledColor =
        isDark ? AppColors.textHintDark : AppColors.textHintLight;

    final rec = recurring.recurring;
    final category = recurring.category;
    final account = recurring.account;
    final isActive = rec.isActive;

    // Calculer la prochaine date (fonction pure, pas de cache)
    final nextDate = calculateNextRecurringDate(rec);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icone de categorie
              Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: category != null
                    ? CategoryIcon.fromHex(
                        icon: IconMapper.getIcon(category.iconKey),
                        colorHex: category.color,
                        size: CategoryIconSize.medium,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: disabledColor,
                          size: 22,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Infos principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom de la categorie + badge inactive
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (rec.note != null && rec.note!.isNotEmpty)
                                ? rec.note!
                                : (category?.name ?? 'Categorie supprimee'),
                            style: AppTextStyles.bodyLarge(
                              color: isActive ? textColor : disabledColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: disabledColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Inactive',
                              style: AppTextStyles.caption(color: disabledColor)
                                  .copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Compte et prochaine date
                    Text(
                      nextDate != null
                          ? '${account.name} - ${_formatNextDate(nextDate)}'
                          : account.name,
                      style: AppTextStyles.caption(
                        color: isActive ? secondaryColor : disabledColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Montant
              Text(
                CurrencyFormatter.format(rec.amount),
                style: AppTextStyles.bodyLarge(
                  color: isActive ? textColor : disabledColor,
                ).copyWith(fontWeight: FontWeight.w600),
              ),

              const SizedBox(width: 8),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: isActive ? secondaryColor : disabledColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNextDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return "Aujourd'hui";
    } else if (difference == 1) {
      return 'Demain';
    } else if (difference < 7) {
      return 'Dans $difference jours';
    } else {
      return DateFormat('d MMM', 'fr_FR').format(date);
    }
  }
}
