import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monasafe/src/common_widgets/common_widgets.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/currency_formatter.dart';
import 'package:monasafe/src/data/models/models.dart';
import 'package:monasafe/src/features/stats/presentation/stats_providers.dart';

/// Graphique des flux de trésorerie (revenus vs dépenses).
///
/// Affiche un LineChart avec deux lignes :
/// - Verte pour les revenus
/// - Rouge pour les dépenses
class CashflowChart extends ConsumerWidget {
  const CashflowChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final cashflowAsync = ref.watch(cashflowDataStreamProvider);

    return GlassCardWithHeader(
      header: Text(
        'Flux de trésorerie',
        style: AppTextStyles.h4(color: textColor),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 20),
      child: AsyncStateHandler<CashflowData>(
        value: cashflowAsync,
        emptyCheck: (data) => switch (data) {
          MonthlyCashflowData(:final data) => data.isEmpty,
          DailyCashflowData(:final data) => data.isEmpty,
        },
        emptyWidget: const SizedBox(
          height: 220,
          child: EmptyStateWidget(
            icon: Icons.show_chart,
            message: 'Aucune donnée disponible',
            padding: EdgeInsets.zero,
          ),
        ),
        loadingWidget: const SizedBox(
          height: 220,
          child: LoadingStateWidget(padding: EdgeInsets.zero),
        ),
        errorBuilder: (_, __) => const SizedBox(
          height: 220,
          child: ErrorStateWidget(
            message: 'Erreur de chargement',
            padding: EdgeInsets.zero,
          ),
        ),
        builder: (data) => switch (data) {
          MonthlyCashflowData(:final data) => _buildMonthlyChart(context, data),
          DailyCashflowData(:final data) => _buildDailyChart(context, data),
        },
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, List<MonthlyStatistics> data) {
    // Filter to only include months with data
    final filteredData = data.where((m) => m.totalIncome > 0 || m.totalExpense > 0).toList();

    if (filteredData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: EmptyStateWidget(
          icon: Icons.show_chart,
          message: 'Aucune transaction cette année',
          padding: EdgeInsets.zero,
        ),
      );
    }

    // Sort by month
    filteredData.sort((a, b) => a.month.compareTo(b.month));

    // Convert to FlSpot
    final incomeSpots = filteredData
        .map((m) => FlSpot(m.month.toDouble(), m.totalIncome))
        .toList();

    final expenseSpots = filteredData
        .map((m) => FlSpot(m.month.toDouble(), m.totalExpense))
        .toList();

    // Calculate max value for Y axis
    final maxIncome = filteredData.fold<double>(0, (max, m) => m.totalIncome > max ? m.totalIncome : max);
    final maxExpense = filteredData.fold<double>(0, (max, m) => m.totalExpense > max ? m.totalExpense : max);
    final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;

    return _buildChartWidget(
      context: context,
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      maxY: maxY,
      getLabelX: (value) => _getMonthLabel(value.toInt()),
      intervalX: 1,
    );
  }

  Widget _buildDailyChart(BuildContext context, List<DailyStatistics> data) {
    // Filter to only include days with data
    final filteredData = data.where((d) => d.totalIncome > 0 || d.totalExpense > 0).toList();

    if (filteredData.isEmpty) {
      return const SizedBox(
        height: 220,
        child: EmptyStateWidget(
          icon: Icons.show_chart,
          message: 'Aucune transaction ce mois',
          padding: EdgeInsets.zero,
        ),
      );
    }

    // Sort by day
    filteredData.sort((a, b) => a.day.compareTo(b.day));

    // Convert to FlSpot
    final incomeSpots = filteredData
        .map((d) => FlSpot(d.day.toDouble(), d.totalIncome))
        .toList();

    final expenseSpots = filteredData
        .map((d) => FlSpot(d.day.toDouble(), d.totalExpense))
        .toList();

    // Calculate max value for Y axis
    final maxIncome = filteredData.fold<double>(0, (max, d) => d.totalIncome > max ? d.totalIncome : max);
    final maxExpense = filteredData.fold<double>(0, (max, d) => d.totalExpense > max ? d.totalExpense : max);
    final maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;

    return _buildChartWidget(
      context: context,
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      maxY: maxY,
      getLabelX: (value) => value.toInt().toString(),
      intervalX: 5, // Afficher tous les 5 jours
    );
  }

  Widget _buildChartWidget({
    required BuildContext context,
    required List<FlSpot> incomeSpots,
    required List<FlSpot> expenseSpots,
    required double maxY,
    required String Function(double) getLabelX,
    required double intervalX,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Prevent division by zero
    final safeMaxY = maxY > 0 ? maxY : 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: safeMaxY,
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: safeMaxY / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: secondaryColor.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: intervalX,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          getLabelX(value),
                          style: AppTextStyles.caption(color: secondaryColor),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: safeMaxY / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        CurrencyFormatter.format(value, compact: true),
                        style: AppTextStyles.caption(color: secondaryColor),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  
                ),
                topTitles: const AxisTitles(
                  
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Income line (green)
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppColors.success,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.success,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                ),
                // Expense line (red)
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppColors.error,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.error,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.cardDark : AppColors.cardLight,
                  tooltipBorder: BorderSide(
                    color: secondaryColor.withValues(alpha: 0.2),
                  ),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isIncome = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isIncome ? "Revenus" : "Dépenses"}\n${CurrencyFormatter.format(spot.y)}',
                        AppTextStyles.caption(
                          color: isIncome ? AppColors.success : AppColors.error,
                        ).copyWith(fontWeight: FontWeight.w600),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        const _ChartLegend(),
      ],
    );
  }

  String _getMonthLabel(int month) {
    const months = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    if (month < 1 || month > 12) return '';
    return months[month];
  }
}

/// Légende du graphique avec les deux lignes.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.success, label: 'Revenus'),
        SizedBox(width: 24),
        _LegendItem(color: AppColors.error, label: 'Dépenses'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall(color: textColor),
        ),
      ],
    );
  }
}
