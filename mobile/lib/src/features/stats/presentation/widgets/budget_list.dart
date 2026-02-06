import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/common_widgets.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/features/stats/presentation/stats_providers.dart';
import 'package:simpleflow/src/features/stats/presentation/stats_state.dart';
import 'package:simpleflow/src/features/stats/presentation/widgets/budget_detail_modal.dart';
import 'package:simpleflow/src/features/stats/presentation/widgets/budget_progress_tile.dart';
import 'package:simpleflow/src/features/stats/presentation/widgets/create_budget_modal.dart';

/// Carte affichant la liste des budgets avec leur progression.
///
/// Affiche un état vide si aucun budget n'est configuré,
/// avec un bouton pour en créer un.
class BudgetList extends ConsumerWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetProgressStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return GlassCardWithHeader(
      header: Text(
        'Budgets',
        style: AppTextStyles.h4(color: textColor),
      ),
      trailing: IconButton(
        onPressed: () => _showCreateBudgetModal(context),
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primary,
        ),
        tooltip: 'Créer un budget',
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Center(
        child: budgetsAsync.when(
          data: (budgets) => _buildBudgetList(context, budgets),
          loading: () => const LoadingStateWidget(
            message: 'Chargement des budgets...',
          ),
          error: (error, _) => ErrorStateWidget(
            message: 'Erreur: $error',
          ),
        ),
      )
    );
  }

  Widget _buildBudgetList(BuildContext context, List<BudgetProgress> budgets) {
    if (budgets.isEmpty) {
      return const _EmptyBudgetState();
    }

    return Column(
      children: budgets
          .map(
            (budget) => BudgetProgressTile(
              budgetProgress: budget,
              onTap: () => BudgetDetailModal.show(context, budget),
            ),
          )
          .toList(),
    );
  }

  void _showCreateBudgetModal(BuildContext context) {
    CreateBudgetModal.show(context);
  }
}

/// État vide affiché quand aucun budget n'est configuré.
class _EmptyBudgetState extends StatelessWidget {
  const _EmptyBudgetState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.savings_outlined,
            size: 48,
            color: secondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun budget configuré',
            style: AppTextStyles.bodyMedium(color: secondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Définissez des limites pour vos catégories',
            style: AppTextStyles.caption(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Créer un budget',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            icon: Icons.add,
            onPressed: () => CreateBudgetModal.show(context),
          ),
        ],
      ),
    );
  }
}
