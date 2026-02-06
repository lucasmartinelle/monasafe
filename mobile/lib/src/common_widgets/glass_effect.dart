import 'dart:ui';

import 'package:flutter/material.dart';

/// Widget réutilisable pour appliquer un effet "Glass" (glassmorphism).
///
/// Applique un BackdropFilter avec un flou gaussien au contenu enfant.
///
/// ```dart
/// GlassEffect(
///   blur: 10,
///   borderRadius: BorderRadius.circular(12),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Contenu avec effet glass'),
///   ),
/// )
/// ```
class GlassEffect extends StatelessWidget {
  const GlassEffect({
    required this.child,
    super.key,
    this.blur = 10.0,
    this.borderRadius,
  });

  /// Widget enfant à afficher avec l'effet glass.
  final Widget child;

  /// Intensité du flou (sigma). Plus élevé = plus flou.
  final double blur;

  /// Border radius pour le clip. Si null, pas de border radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final filter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: BackdropFilter(
          filter: filter,
          child: child,
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: filter,
        child: child,
      ),
    );
  }
}
