import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/features/stats/presentation/stats_providers.dart';
import 'package:monasafe/src/features/stats/presentation/stats_state.dart';

/// Sélecteur de période pour les statistiques.
///
/// Permet de choisir entre "Ce mois", "Mois dernier" et "Année".
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return SelectableBadgeGroup<PeriodType>(
      items: PeriodType.values,
      selectedItem: selectedPeriod,
      labelBuilder: (period) => period.label,
      colorBuilder: (_) => AppColors.primary,
      onSelected: (period) {
        ref.read(selectedPeriodProvider.notifier).select(period);
      },
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
