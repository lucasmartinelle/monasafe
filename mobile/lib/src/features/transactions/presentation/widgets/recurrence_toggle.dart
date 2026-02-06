import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/icon_label_tile.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/features/transactions/presentation/transaction_form_provider.dart';

/// Toggle switch for recurring payment option.
///
/// Can be used in two modes:
/// 1. Connected to transactionFormNotifierProvider (default)
/// 2. Standalone with explicit isRecurring and onChanged
class RecurrenceToggle extends ConsumerWidget {
  const RecurrenceToggle({
    super.key,
    this.isRecurring,
    this.onChanged,
  });

  /// Current recurring state. If null, reads from provider.
  final bool? isRecurring;

  /// Callback when value changes. If null, uses provider.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(transactionFormNotifierProvider);
    final recurring = isRecurring ?? formState.isRecurring;
    final isLinkedToRecurrence = formState.isLinkedToRecurrence;
    final isEditMode = formState.isEditMode;
    final isIncome = formState.type == CategoryType.income;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isActive = recurring;

    // Labels selon le type de transaction
    final label = isIncome ? 'Revenu récurrent' : 'Paiement récurrent';

    // Si la transaction est liee a une recurrence existante
    if (isLinkedToRecurrence) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconLabelTile(
            icon: Icons.repeat,
            iconColor: AppColors.primary,
            label: label,
            subtitle: 'Lié à une récurrence',
            trailing: Switch.adaptive(
              value: true,
              onChanged: null,
              activeColor: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
            child: Text(
              'Pour modifier ou désactiver la récurrence, rendez-vous dans l\'onglet "Récurrences".',
              style: AppTextStyles.caption(color: subtitleColor),
            ),
          ),
        ],
      );
    }

    // En mode edition, ne pas permettre d'activer la recurrence
    if (isEditMode) {
      return const SizedBox.shrink();
    }

    // Mode creation : toggle actif
    return IconLabelTile(
      icon: Icons.repeat,
      iconColor: isActive ? AppColors.primary : subtitleColor,
      label: label,
      subtitle: 'Se répète chaque mois',
      trailing: Switch.adaptive(
        value: isActive,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          } else {
            ref
                .read(transactionFormNotifierProvider.notifier)
                .setRecurring(value);
          }
        },
        activeColor: AppColors.primary,
      ),
    );
  }
}
