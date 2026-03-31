import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/data/providers/database_providers.dart';
import 'package:monasafe/src/features/aggregators/app_shell/presentation/app_navigation_bar.dart';
import 'package:monasafe/src/features/aggregators/dashboard/presentation/dashboard_providers.dart';
import 'package:monasafe/src/features/aggregators/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:monasafe/src/features/aggregators/settings/presentation/screens/settings_screen.dart';
import 'package:monasafe/src/features/domain/recurring/presentation/screens/recurring_list_screen.dart';
import 'package:monasafe/src/features/domain/stats/presentation/screens/stats_screen.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:monasafe/src/features/domain/transactions/presentation/screens/add_transfer_screen.dart';

/// Main app shell with bottom navigation and FAB.
///
/// Uses IndexedStack to preserve state between navigation tabs.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatsScreen(),
    RecurringListScreen(),
    SettingsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _onFabPressed() async {
    final accounts = ref.read(accountsStreamProvider).valueOrNull;
    final hasMultipleAccounts = (accounts?.length ?? 0) >= 2;

    if (!hasMultipleAccounts) {
      await _openAddTransaction();
      return;
    }

    if (!mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FabOptionsSheet(),
    );

    if (!mounted) return;
    if (choice == 'transaction') {
      await _openAddTransaction();
    } else if (choice == 'transfer') {
      await _openAddTransfer();
    }
  }

  Future<void> _openAddTransaction() async {
    final result = await AddTransactionScreen.show(context);
    if ((result ?? false) && mounted) {
      unawaited(ref.read(paginatedTransactionsProvider.notifier).refresh());
    }
  }

  Future<void> _openAddTransfer() async {
    final result = await AddTransferScreen.show(context);
    if ((result ?? false) && mounted) {
      unawaited(ref.read(paginatedTransactionsProvider.notifier).refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.process,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

/// Bottom sheet présentant le choix entre transaction et virement.
class _FabOptionsSheet extends StatelessWidget {
  const _FabOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Option : Nouvelle transaction
          _OptionTile(
            icon: Icons.add_circle_outline,
            iconColor: AppColors.process,
            title: 'Nouvelle transaction',
            subtitle: 'Ajouter une dépense ou un revenu',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => Navigator.of(context).pop('transaction'),
          ),

          const SizedBox(height: 4),

          // Option : Virement
          _OptionTile(
            icon: Icons.swap_horiz,
            iconColor: AppColors.primary,
            title: 'Virement entre comptes',
            subtitle: "Transférer de l'argent entre vos comptes",
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => Navigator.of(context).pop('transfer'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.labelMedium(color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.caption(color: textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
