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

/// Main app shell with bottom navigation and expandable FAB.
///
/// Uses IndexedStack to preserve state between navigation tabs.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _fabExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatsScreen(),
    RecurringListScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_fabExpanded) _closeFab();
    setState(() => _currentIndex = index);
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    if (_fabExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeFab() {
    setState(() => _fabExpanded = false);
    _animationController.reverse();
  }

  Future<void> _openAddTransaction() async {
    _closeFab();
    final result = await AddTransactionScreen.show(context);
    if ((result ?? false) && mounted) {
      unawaited(ref.read(paginatedTransactionsProvider.notifier).refresh());
    }
  }

  Future<void> _openAddTransfer() async {
    _closeFab();
    final result = await AddTransferScreen.show(context);
    if ((result ?? false) && mounted) {
      unawaited(ref.read(paginatedTransactionsProvider.notifier).refresh());
    }
  }

  /// Retourne true si l'utilisateur a au moins 2 comptes (virement possible).
  bool get _hasMultipleAccounts {
    final accounts = ref.read(accountsStreamProvider).valueOrNull;
    return (accounts?.length ?? 0) >= 2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _fabExpanded ? _closeFab : null,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppNavigationBar(
          currentIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      ),
    );
  }

  Widget _buildFab() {
    final hasMultipleAccounts = _hasMultipleAccounts;

    // Si un seul compte : comportement original (ouverture directe)
    if (!hasMultipleAccounts) {
      return FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: AppColors.process,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      );
    }

    // Plusieurs comptes : speed dial
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Options du speed dial
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _expandAnimation,
              child: SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SpeedDialItem(
                        label: 'Virement',
                        icon: Icons.swap_horiz,
                        color: AppColors.primary,
                        onTap: _openAddTransfer,
                      ),
                      const SizedBox(height: 10),
                      _SpeedDialItem(
                        label: 'Transaction',
                        icon: Icons.add,
                        color: AppColors.process,
                        onTap: _openAddTransaction,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // FAB principal
        FloatingActionButton(
          onPressed: _toggleFab,
          backgroundColor: _fabExpanded ? AppColors.primaryDark : AppColors.process,
          foregroundColor: Colors.white,
          elevation: 4,
          child: AnimatedRotation(
            turns: _fabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

/// Bouton d'option du speed dial avec label.
class _SpeedDialItem extends StatelessWidget {
  const _SpeedDialItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label
        Material(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: AppTextStyles.labelMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Mini FAB
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}
