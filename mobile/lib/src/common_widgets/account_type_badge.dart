import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';

/// Badge affichant le type de compte avec son solde.
class AccountTypeBadge extends StatelessWidget {
  const AccountTypeBadge({
    required this.type,
    required this.balance,
    super.key,
  });

  final AccountType type;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.isDark
        ? AppColors.primary.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getAccountTypeIcon(type),
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${getAccountTypeLabel(type)} ${CurrencyFormatter.format(balance)}',
            style: AppTextStyles.caption(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Retourne l'icône pour un type de compte.
IconData getAccountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.checking => Icons.account_balance,
    AccountType.savings => Icons.savings,
    AccountType.cash => Icons.payments,
  };
}

/// Retourne le label français pour un type de compte.
String getAccountTypeLabel(AccountType type) {
  return switch (type) {
    AccountType.checking => 'Courant',
    AccountType.savings => 'Épargne',
    AccountType.cash => 'Espèces',
  };
}
