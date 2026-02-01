import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';

/// Tailles disponibles pour IconContainer
enum IconContainerSize {
  /// 32x32px, icône 16px
  small,

  /// 40x40px, icône 20px
  medium,

  /// 48x48px, icône 24px
  large,

  /// 64x64px, icône 32px
  extraLarge,
}

/// Forme du conteneur d'icône
enum IconContainerShape {
  /// Cercle
  circle,

  /// Rectangle arrondi
  rounded,

  /// Carré avec coins légèrement arrondis
  square,
}

/// Conteneur d'icône avec fond coloré.
///
/// Peut afficher soit une icône via [icon], soit un widget personnalisé via [child].
/// Au moins l'un des deux doit être fourni.
///
/// ```dart
/// // Avec une icône
/// IconContainer(
///   icon: Icons.wallet,
///   color: AppColors.primary,
///   size: IconContainerSize.large,
/// )
///
/// // Avec un widget personnalisé
/// IconContainer(
///   color: Colors.blue,
///   size: IconContainerSize.large,
///   child: Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
/// )
/// ```
class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    this.icon,
    this.child,
    this.color,
    this.backgroundColor,
    this.size = IconContainerSize.medium,
    this.shape = IconContainerShape.rounded,
    this.backgroundOpacity = 0.15,
    this.onTap,
    this.customSize,
    this.customIconSize,
    this.customBorderRadius,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  /// Icône à afficher (prioritaire sur child)
  final IconData? icon;

  /// Widget enfant personnalisé (utilisé si icon est null)
  final Widget? child;

  /// Couleur de l'icône (défaut: AppColors.primary)
  final Color? color;

  /// Couleur de fond personnalisée (prioritaire sur color + opacity)
  final Color? backgroundColor;

  /// Taille du conteneur
  final IconContainerSize size;

  /// Forme du conteneur
  final IconContainerShape shape;

  /// Opacité du fond (utilisée si backgroundColor n'est pas fourni)
  final double backgroundOpacity;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Taille personnalisée du conteneur (prioritaire sur size)
  final double? customSize;

  /// Taille personnalisée de l'icône (prioritaire sur size)
  final double? customIconSize;

  /// Border radius personnalisé (prioritaire sur shape)
  final double? customBorderRadius;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primary;
    final bgColor = backgroundColor ?? iconColor.withValues(alpha: backgroundOpacity);
    final containerSize = customSize ?? _getContainerSize();
    final iconSize = customIconSize ?? _getIconSize();
    final borderRadius = customBorderRadius ?? _getBorderRadius(containerSize);

    final content = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: shape == IconContainerShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        shape: shape == IconContainerShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: iconSize, color: iconColor)
            : child,
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
      IconContainerSize.small => 32,
      IconContainerSize.medium => 40,
      IconContainerSize.large => 48,
      IconContainerSize.extraLarge => 64,
    };
  }

  double _getIconSize() {
    return switch (size) {
      IconContainerSize.small => 16,
      IconContainerSize.medium => 20,
      IconContainerSize.large => 24,
      IconContainerSize.extraLarge => 32,
    };
  }

  double _getBorderRadius(double containerSize) {
    return switch (shape) {
      IconContainerShape.circle => containerSize / 2,
      IconContainerShape.rounded => 12,
      IconContainerShape.square => 8,
    };
  }
}
