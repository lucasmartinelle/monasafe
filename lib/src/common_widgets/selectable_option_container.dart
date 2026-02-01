import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/theme_helper.dart';

/// Conteneur animé avec état de sélection.
///
/// Affiche une bordure et un fond coloré quand sélectionné.
/// Utilisé pour les options de type tabs, grilles de catégories, etc.
///
/// ```dart
/// SelectableOptionContainer(
///   isSelected: selectedId == item.id,
///   onTap: () => setState(() => selectedId = item.id),
///   child: Row(
///     children: [
///       Icon(item.icon),
///       Text(item.label),
///     ],
///   ),
/// )
/// ```
class SelectableOptionContainer extends StatelessWidget {
  const SelectableOptionContainer({
    required this.isSelected, required this.child, super.key,
    this.onTap,
    this.selectedColor,
    this.padding,
    this.borderRadius = 12,
    this.selectedBorderWidth = 2,
    this.selectedBackgroundOpacity = 0.15,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHapticFeedback = true,
  });

  /// Indique si l'option est sélectionnée
  final bool isSelected;

  /// Contenu du conteneur
  final Widget child;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Couleur de sélection (défaut: AppColors.primary)
  final Color? selectedColor;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Rayon des bords arrondis
  final double borderRadius;

  /// Largeur de la bordure quand sélectionné
  final double selectedBorderWidth;

  /// Opacité du fond quand sélectionné (0.0 à 1.0)
  final double selectedBackgroundOpacity;

  /// Durée de l'animation de transition
  final Duration animationDuration;

  /// Active le retour haptique au tap
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        if (enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: selectedBackgroundOpacity)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: color, width: selectedBorderWidth)
              : Border.all(color: Colors.transparent, width: selectedBorderWidth),
        ),
        child: child,
      ),
    );
  }
}

/// Variante horizontale pour les tabs.
///
/// ```dart
/// SelectableTab(
///   isSelected: currentTab == 0,
///   onTap: () => setState(() => currentTab = 0),
///   icon: Icons.arrow_downward,
///   label: 'Dépense',
/// )
/// ```
class SelectableTab extends StatelessWidget {
  const SelectableTab({
    required this.isSelected, required this.label, super.key,
    this.icon,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
  });

  /// Indique si le tab est sélectionné
  final bool isSelected;

  /// Libellé du tab
  final String label;

  /// Icône optionnelle
  final IconData? icon;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Couleur quand sélectionné
  final Color? selectedColor;

  /// Couleur quand non sélectionné
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedColor ?? AppColors.primary;
    final inactiveColor = unselectedColor ?? context.textSecondary;
    final color = isSelected ? activeColor : inactiveColor;

    return SelectableOptionContainer(
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: activeColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
