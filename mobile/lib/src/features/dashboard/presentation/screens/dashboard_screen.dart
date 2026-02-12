import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/theme/theme_helper.dart';
import 'package:monasafe/src/features/accounts/accounts.dart';
import 'package:monasafe/src/features/dashboard/presentation/widgets/account_selector.dart';
import 'package:monasafe/src/features/dashboard/presentation/widgets/expense_breakdown_card.dart';
import 'package:monasafe/src/features/dashboard/presentation/widgets/net_worth_card.dart';
import 'package:monasafe/src/features/dashboard/presentation/widgets/recent_transactions_card.dart';

/// Main dashboard screen displaying financial overview.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monasafe',
                      style: AppTextStyles.h2(color: context.textPrimary),
                    ),
                  ],
                ),
              ),
            ),

            // Net Worth Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: NetWorthCard(),
              ),
            ),

            // Account List Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: AccountListCard(),
              ),
            ),

            // Account Selector
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AccountSelector(),
              ),
            ),

            // Expense Breakdown Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ExpenseBreakdownCard(),
              ),
            ),

            // Recent Transactions Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: RecentTransactionsCard(),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }
}
