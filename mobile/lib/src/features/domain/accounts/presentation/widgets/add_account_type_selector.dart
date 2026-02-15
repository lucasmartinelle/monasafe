import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/account_type.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/domain/accounts/presentation/account_form_provider.dart';

/// Selecteur de type de compte dans le formulaire de creation de compte.
class AddAccountTypeSelector extends ConsumerWidget {
  const AddAccountTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(accountFormNotifierProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    final accounts = accountsAsync.valueOrNull ?? [];
    final existingTypes = accounts.map((a) => a.type).toSet();

    // Types disponibles a creer
    final availableTypes = [AccountType.checking, AccountType.savings]
        .where((t) => !existingTypes.contains(t))
        .toList();

    if (availableTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Tous les types de comptes ont déjà été créés.',
          style: AppTextStyles.bodySmall(color: AppColors.warning),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de compte',
          style: AppTextStyles.labelMedium(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: availableTypes.map((type) {
            final isSelected = state.selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != availableTypes.last ? 12 : 0,
                ),
                child: _AccountTypeOption(
                  type: type,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => ref
                      .read(accountFormNotifierProvider.notifier)
                      .setType(type),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.type,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final AccountType type;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final iconColor = isSelected ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Column(
          children: [
            Icon(
              getAccountTypeIcon(type),
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              getAccountTypeLabel(type),
              style: AppTextStyles.labelMedium(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
