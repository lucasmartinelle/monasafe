import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';

/// Navigation destinations for the app.
enum AppDestination {
  dashboard(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Accueil',
  ),
  stats(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    label: 'Stats',
  ),
  recurring(
    icon: Icons.event_repeat_outlined,
    selectedIcon: Icons.event_repeat,
    label: 'Récurrences',
  ),
  settings(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Reglages',
  );

  const AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation bar for the app with 4 tabs.
///
/// Uses a notched shape to accommodate the centered FAB.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    const selectedColor = AppColors.primary;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: backgroundColor,
      elevation: 8,
      height: 60,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              context,
              destination: AppDestination.dashboard,
              index: 0,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              destination: AppDestination.stats,
              index: 1,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ),
          // Space for FAB
          const Expanded(child: SizedBox()),
          Expanded(
            child: _buildNavItem(
              context,
              destination: AppDestination.recurring,
              index: 2,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              destination: AppDestination.settings,
              index: 3,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required AppDestination destination,
    required int index,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? selectedColor : unselectedColor;
    final icon = isSelected ? destination.selectedIcon : destination.icon;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 6 : 0,
            height: isSelected ? 6 : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
