import 'package:flutter/material.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';

/// Widget affichant une icône centrée dans un cercle coloré.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.iconKey, required this.color, super.key,
    this.size = CategoryIconSize.medium,
    this.onTap,
  });

  factory CategoryIcon.fromHex({
    required String iconKey, required int colorHex, Key? key,
    CategoryIconSize size = CategoryIconSize.medium,
    VoidCallback? onTap,
  }) {
    return CategoryIcon(
      key: key,
      iconKey: iconKey,
      color: Color(colorHex),
      size: size,
      onTap: onTap,
    );
  }

  final String iconKey;
  final Color color;
  final CategoryIconSize size;
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
          lucideIconFromKey(iconKey),
          size: iconSize,
          color: iconColor,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
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

  Color _getDarkerColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .toColor();
  }
}

enum CategoryIconSize {
  small,
  medium,
  large,
  extraLarge,
}
