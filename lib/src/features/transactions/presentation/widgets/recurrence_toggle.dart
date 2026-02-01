import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/icon_label_tile.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
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
    final recurring = isRecurring ??
        ref.watch(transactionFormNotifierProvider.select((s) => s.isRecurring));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final isActive = recurring ?? false;

    return IconLabelTile(
      icon: Icons.repeat,
      iconColor: isActive ? AppColors.primary : subtitleColor,
      label: 'Paiement récurrent',
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
