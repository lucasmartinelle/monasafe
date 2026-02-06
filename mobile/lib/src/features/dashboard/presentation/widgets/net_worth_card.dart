import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simpleflow/src/common_widgets/glass_card.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/theme/theme_helper.dart';
import 'package:simpleflow/src/core/utils/currency_formatter.dart';
import 'package:simpleflow/src/data/providers/database_providers.dart';

/// Card displaying the total net worth.
class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialSummary = ref.watch(financialSummaryStreamProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Solde total',
            style: AppTextStyles.labelMedium(color: context.textSecondary),
          ),
          const SizedBox(height: 8),
          financialSummary.when(
            data: (summary) => Text(
              CurrencyFormatter.format(summary.totalBalance),
              style: AppTextStyles.h1(color: context.textPrimary),
            ),
            loading: () => _buildBalanceSkeleton(context),
            error: (_, __) => Text(
              '--,-- €',
              style: AppTextStyles.h1(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSkeleton(BuildContext context) {
    return Container(
      height: 38,
      width: 180,
      decoration: BoxDecoration(
        color: context.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
