import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/features/app_shell/presentation/app_navigation_bar.dart';
import 'package:monasafe/src/features/dashboard/presentation/dashboard_providers.dart';
import 'package:monasafe/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:monasafe/src/features/recurring/recurring.dart';
import 'package:monasafe/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:monasafe/src/features/stats/presentation/screens/stats_screen.dart';
import 'package:monasafe/src/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:monasafe/src/features/transactions/presentation/transaction_form_provider.dart';

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
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _onFabPressed() async {
    final result = await AddTransactionScreen.show(context);

    // Refresh transaction list and reset form if a transaction was added
    if ((result ?? false) && mounted) {
      ref.read(transactionFormNotifierProvider.notifier).reset();
      ref.read(paginatedTransactionsProvider.notifier).refresh();
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
