import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/data/models/models.dart';
import 'package:simpleflow/src/features/recurring/presentation/recurring_providers.dart';
import 'package:simpleflow/src/features/recurring/presentation/widgets/recurring_detail_modal.dart';
import 'package:simpleflow/src/features/recurring/presentation/widgets/recurring_tile.dart';

/// Ecran listant toutes les transactions recurrentes.
class RecurringListScreen extends ConsumerWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final recurringsAsync = ref.watch(recurringWithDetailsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: recurringsAsync.when(
        data: (recurrings) {
          if (recurrings.isEmpty) {
            return _EmptyState(
              isDark: isDark,
              textColor: textColor,
              secondaryColor: secondaryColor,
            );
          }

          // Separer actives et inactives
          final active = recurrings.where((r) => r.recurring.isActive).toList();
          final inactive =
              recurrings.where((r) => !r.recurring.isActive).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  'Récurrences',
                  style: AppTextStyles.h2(color: textColor),
                ),
                const SizedBox(height: 24),

                // Section Actives
                if (active.isNotEmpty) ...[
                  Text(
                    'Actives',
                    style: AppTextStyles.labelMedium(color: secondaryColor),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: _buildTileList(context, active, cardColor, isDark),
                    ),
                  ),
                ],

                // Section Inactives
                if (inactive.isNotEmpty) ...[
                  if (active.isNotEmpty) const SizedBox(height: 24),
                  Text(
                    'Inactives',
                    style: AppTextStyles.labelMedium(color: secondaryColor),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children:
                          _buildTileList(context, inactive, cardColor, isDark),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Les paiements recurrents sont generes automatiquement chaque mois.',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingStateWidget(
          message: 'Chargement des recurrences...',
        ),
        error: (error, stack) => ErrorStateWidget(
          message: 'Erreur: $error',
          onRetry: () => ref.invalidate(recurringWithDetailsProvider),
        ),
      ),
      ),
    );
  }

  List<Widget> _buildTileList(
    BuildContext context,
    List<RecurringTransactionWithDetails> items,
    Color cardColor,
    bool isDark,
  ) {
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return [
      for (int i = 0; i < items.length; i++) ...[
        RecurringTile(
          recurring: items[i],
          onTap: () => _openDetail(context, items[i]),
        ),
        if (i < items.length - 1)
          Divider(
            height: 1,
            indent: 72,
            color: dividerColor,
          ),
      ],
    ];
  }

  Future<void> _openDetail(
    BuildContext context,
    RecurringTransactionWithDetails recurring,
  ) async {
    await RecurringDetailModal.show(context, recurring);
  }
}

/// Etat vide quand aucune recurrence.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isDark,
    required this.textColor,
    required this.secondaryColor,
  });

  final bool isDark;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Récurrences',
            style: AppTextStyles.h2(color: textColor),
          ),
          const SizedBox(height: 80),

          // Contenu vide
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.event_repeat,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucun paiement recurrent',
                  style: AppTextStyles.h4(color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Creez une transaction avec l\'option "Recurrente" activee pour la voir apparaitre ici.',
                    style: AppTextStyles.bodyMedium(color: secondaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
