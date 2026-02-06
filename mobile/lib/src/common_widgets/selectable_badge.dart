import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/theme/theme_helper.dart';

/// Badge/Chip sélectionnable avec bordure et fond coloré.
///
/// Utilisé pour les filtres, sélecteurs de compte, badges de type, etc.
///
/// ```dart
/// SelectableBadge(
///   label: 'Compte courant',
///   icon: Icons.account_balance,
///   isSelected: selectedAccount == 'checking',
///   color: AppColors.primary,
///   onTap: () => setState(() => selectedAccount = 'checking'),
/// )
/// ```
class SelectableBadge extends StatelessWidget {
  const SelectableBadge({
    required this.label, super.key,
    this.icon,
    this.isSelected = false,
    this.color,
    this.onTap,
    this.padding,
    this.borderRadius = 20,
    this.selectedBackgroundOpacity = 0.15,
    this.unselectedBackgroundOpacity = 0.08,
    this.showBorderWhenSelected = true,
    this.enableHapticFeedback = true,
  });

  /// Libellé du badge
  final String label;

  /// Icône optionnelle (affichée à gauche du label)
  final IconData? icon;

  /// Indique si le badge est sélectionné
  final bool isSelected;

  /// Couleur principale du badge
  final Color? color;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Rayon des bords arrondis
  final double borderRadius;

  /// Opacité du fond quand sélectionné
  final double selectedBackgroundOpacity;

  /// Opacité du fond quand non sélectionné
  final double unselectedBackgroundOpacity;

  /// Affiche une bordure quand sélectionné
  final bool showBorderWhenSelected;

  /// Active le retour haptique
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;
    final textColor = isSelected ? badgeColor : context.textSecondary;
    final bgOpacity = isSelected ? selectedBackgroundOpacity : unselectedBackgroundOpacity;
    final bgColor = badgeColor.withValues(alpha: bgOpacity);

    return GestureDetector(
      onTap: () {
        if (enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected && showBorderWhenSelected
              ? Border.all(color: badgeColor, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall(color: textColor).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge coloré simple (non sélectionnable).
///
/// ```dart
/// ColoredBadge(
///   label: 'Épargne',
///   icon: Icons.savings,
///   color: Colors.blue,
/// )
/// ```
class ColoredBadge extends StatelessWidget {
  const ColoredBadge({
    required this.label, super.key,
    this.icon,
    this.color,
    this.padding,
    this.borderRadius = 20,
    this.backgroundOpacity = 0.15,
    this.onTap,
  });

  /// Libellé du badge
  final String label;

  /// Icône optionnelle
  final IconData? icon;

  /// Couleur du badge
  final Color? color;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Rayon des bords arrondis
  final double borderRadius;

  /// Opacité du fond
  final double backgroundOpacity;

  /// Callback optionnel
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;
    final bgColor = badgeColor.withValues(alpha: backgroundOpacity);

    final content = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: badgeColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall(color: badgeColor).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Groupe de badges sélectionnables (sélection unique).
///
/// ```dart
/// SelectableBadgeGroup<String>(
///   items: ['Tous', 'Revenus', 'Dépenses'],
///   selectedItem: selectedFilter,
///   labelBuilder: (item) => item,
///   onSelected: (item) => setState(() => selectedFilter = item),
/// )
/// ```
class SelectableBadgeGroup<T> extends StatelessWidget {
  const SelectableBadgeGroup({
    required this.items, required this.selectedItem, required this.labelBuilder, required this.onSelected, super.key,
    this.iconBuilder,
    this.colorBuilder,
    this.spacing = 8,
    this.scrollable = true,
    this.padding,
  });

  /// Liste des éléments
  final List<T> items;

  /// Élément actuellement sélectionné
  final T? selectedItem;

  /// Fonction pour obtenir le label d'un élément
  final String Function(T item) labelBuilder;

  /// Callback appelé lors de la sélection
  final ValueChanged<T> onSelected;

  /// Fonction optionnelle pour obtenir l'icône d'un élément
  final IconData? Function(T item)? iconBuilder;

  /// Fonction optionnelle pour obtenir la couleur d'un élément
  final Color? Function(T item)? colorBuilder;

  /// Espacement entre les badges
  final double spacing;

  /// Permet le scroll horizontal
  final bool scrollable;

  /// Padding autour du groupe
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final badges = items.map((item) {
      return Padding(
        padding: EdgeInsets.only(right: spacing),
        child: SelectableBadge(
          label: labelBuilder(item),
          icon: iconBuilder?.call(item),
          color: colorBuilder?.call(item),
          isSelected: item == selectedItem,
          onTap: () => onSelected(item),
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: badges),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: badges,
      ),
    );
  }
}
