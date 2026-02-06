import 'package:flutter/material.dart';

/// Widget affichant une icône centrée dans un cercle coloré.
///
/// Utilisé pour représenter visuellement les catégories de transactions.
///
/// ```dart
/// CategoryIcon(
///   icon: Icons.restaurant,
///   color: Colors.orange,
///   size: CategoryIconSize.medium,
/// )
/// ```
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.icon, required this.color, super.key,
    this.size = CategoryIconSize.medium,
    this.onTap,
  });

  /// Crée un CategoryIcon à partir d'une couleur hexadécimale.
  factory CategoryIcon.fromHex({
    required IconData icon, required int colorHex, Key? key,
    CategoryIconSize size = CategoryIconSize.medium,
    VoidCallback? onTap,
  }) {
    return CategoryIcon(
      key: key,
      icon: icon,
      color: Color(colorHex),
      size: size,
      onTap: onTap,
    );
  }

  /// Icône à afficher
  final IconData icon;

  /// Couleur de fond du cercle
  final Color color;

  /// Taille du widget
  final CategoryIconSize size;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final containerSize = _getContainerSize();
    final iconSize = _getIconSize();
    final backgroundColor = color.withValues(alpha: 0.15);
    final iconColor = _getDarkerColor(color);

    final content = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  double _getContainerSize() {
    return switch (size) {
      CategoryIconSize.small => 32,
      CategoryIconSize.medium => 44,
      CategoryIconSize.large => 56,
      CategoryIconSize.extraLarge => 72,
    };
  }

  double _getIconSize() {
    return switch (size) {
      CategoryIconSize.small => 16,
      CategoryIconSize.medium => 22,
      CategoryIconSize.large => 28,
      CategoryIconSize.extraLarge => 36,
    };
  }

  /// Retourne une version plus foncée de la couleur pour l'icône.
  Color _getDarkerColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Tailles disponibles pour CategoryIcon
enum CategoryIconSize {
  /// 32x32px, icône 16px
  small,

  /// 44x44px, icône 22px
  medium,

  /// 56x56px, icône 28px
  large,

  /// 72x72px, icône 36px
  extraLarge,
}

/// Widget affichant une grille de CategoryIcon pour sélection.
///
/// ```dart
/// CategoryIconPicker(
///   icons: availableIcons,
///   selectedIcon: currentIcon,
///   selectedColor: currentColor,
///   onIconSelected: (icon) => setState(() => currentIcon = icon),
/// )
/// ```
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    required this.icons, required this.color, super.key,
    this.selectedIcon,
    this.onIconSelected,
    this.crossAxisCount = 5,
    this.spacing = 12,
  });

  /// Liste des icônes disponibles
  final List<IconData> icons;

  /// Couleur à appliquer aux icônes
  final Color color;

  /// Icône actuellement sélectionnée
  final IconData? selectedIcon;

  /// Callback appelé lors de la sélection d'une icône
  final ValueChanged<IconData>? onIconSelected;

  /// Nombre de colonnes dans la grille
  final int crossAxisCount;

  /// Espacement entre les icônes
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = icon == selectedIcon;

        return _SelectableCategoryIcon(
          icon: icon,
          color: color,
          isSelected: isSelected,
          onTap: onIconSelected != null ? () => onIconSelected!(icon) : null,
        );
      },
    );
  }
}

class _SelectableCategoryIcon extends StatelessWidget {
  const _SelectableCategoryIcon({
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: color, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(2),
        child: CategoryIcon(
          icon: icon,
          color: color,
        ),
      ),
    );
  }
}
