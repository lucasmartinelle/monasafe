import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/features/stats/presentation/widgets/budget_list.dart';
import 'package:monasafe/src/features/stats/presentation/widgets/cashflow_chart.dart';
import 'package:monasafe/src/features/stats/presentation/widgets/period_selector.dart';

/// Écran des statistiques et budgets.
///
/// Affiche :
/// - Un sélecteur de période (Ce mois, Mois dernier, Année)
/// - Un graphique des flux de trésorerie (revenus vs dépenses)
/// - La liste des budgets avec leur progression
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Statistiques',
                  style: AppTextStyles.h2(color: textColor),
                ),
              ),
            ),

            // Period selector
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: PeriodSelector(),
              ),
            ),

            // Cashflow chart
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: CashflowChart(),
              ),
            ),

            // Budget list
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: BudgetList(),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}
