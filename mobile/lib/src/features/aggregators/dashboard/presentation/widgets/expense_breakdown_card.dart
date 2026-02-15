import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/async_state_handler.dart';
import 'package:monasafe/src/common_widgets/glass_card.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/aggregators/dashboard/presentation/dashboard_providers.dart';

/// Card displaying monthly expenses breakdown as a PieChart with legend.
class ExpenseBreakdownCard extends ConsumerWidget {
  const ExpenseBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final expensesAsync = ref.watch(currentMonthExpensesStreamProvider);

    return GlassCardWithHeader(
      header: Text(
        'Dépenses du mois',
        style: AppTextStyles.h4(color: textColor),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: AsyncStateHandler<List<CategoryStatistics>>(
        value: expensesAsync,
        emptyCheck: (expenses) => expenses.isEmpty,
        emptyWidget: const SizedBox(
          height: 180,
          child: EmptyStateWidget(
            icon: Icons.pie_chart_outline,
            message: 'Aucune dépense ce mois',
            padding: EdgeInsets.zero,
          ),
        ),
        loadingWidget: const SizedBox(
          height: 180,
          child: LoadingStateWidget(padding: EdgeInsets.zero),
        ),
        errorBuilder: (_, __) => const SizedBox(
          height: 180,
          child: ErrorStateWidget(
            message: 'Erreur de chargement',
            padding: EdgeInsets.zero,
          ),
        ),
        builder: (expenses) => _buildChart(context, expenses),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<CategoryStatistics> expenses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Calculate total for percentages
    final total = expenses.fold<double>(0, (sum, e) => sum + e.total);

    // Prepare data: top 4 + "Others" if more than 4
    final chartData = <_ChartData>[];
    double othersTotal = 0;

    for (var i = 0; i < expenses.length; i++) {
      if (i < 4) {
        chartData.add(_ChartData(
          name: expenses[i].categoryName,
          value: expenses[i].total,
          color: Color(expenses[i].color),
          percentage: expenses[i].total / total * 100,
        ));
      } else {
        othersTotal += expenses[i].total;
      }
    }

    if (othersTotal > 0) {
      chartData.add(_ChartData(
        name: 'Autres',
        value: othersTotal,
        color: Colors.grey,
        percentage: othersTotal / total * 100,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: chartData.map((data) {
                return PieChartSectionData(
                  color: data.color,
                  value: data.value,
                  title: '',
                  radius: 35,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Total in center text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: AppTextStyles.caption(color: subtitleColor),
              ),
              Text(
                CurrencyFormatter.format(total),
                style: AppTextStyles.h4(color: textColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ...chartData.map((data) => _LegendItem(data: data)),
      ],
    );
  }
}

class _ChartData {

  _ChartData({
    required this.name,
    required this.value,
    required this.color,
    required this.percentage,
  });
  final String name;
  final double value;
  final Color color;
  final double percentage;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.data});

  final _ChartData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.name,
              style: AppTextStyles.bodySmall(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${data.percentage.toStringAsFixed(1)}%',
            style: AppTextStyles.caption(color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
