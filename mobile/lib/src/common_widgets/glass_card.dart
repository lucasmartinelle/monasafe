import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/theme_helper.dart';

/// Carte avec effet "Glass" (glassmorphism).
///
/// Utilise BackdropFilter pour créer un effet de flou et un fond semi-transparent.
/// Idéal pour les panneaux du dashboard.
///
/// ```dart
/// GlassCard(
///   child: Column(
///     children: [
///       Text('Solde total'),
///       Text('€12,450.23'),
///     ],
///   ),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child, super.key,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blurSigma = 10,
    this.opacity = 0.7,
    this.borderOpacity = 0.2,
    this.shadowOpacity = 0.1,
    this.onTap,
    this.width,
    this.height,
  });

  /// Contenu de la carte
  final Widget child;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Margin externe
  final EdgeInsetsGeometry? margin;

  /// Rayon des bords arrondis
  final double borderRadius;

  /// Intensité du flou (plus élevé = plus flou)
  final double blurSigma;

  /// Opacité du fond (0.0 à 1.0)
  final double opacity;

  /// Opacité de la bordure (0.0 à 1.0)
  final double borderOpacity;

  /// Opacité de l'ombre (0.0 à 1.0)
  final double shadowOpacity;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Largeur fixe (optionnel)
  final double? width;

  /// Hauteur fixe (optionnel)
  final double? height;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _getBackgroundColor(context.isDark),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: _getBorderColor(context.isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowOpacity),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );

    final Widget wrappedCard = margin != null
        ? Padding(padding: margin!, child: card)
        : card;

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: wrappedCard,
      );
    }

    return wrappedCard;
  }

  Color _getBackgroundColor(bool isDark) {
    if (isDark) {
      return AppColors.cardDark.withValues(alpha: opacity);
    }
    return AppColors.cardLight.withValues(alpha: opacity);
  }

  Color _getBorderColor(bool isDark) {
    if (isDark) {
      return Colors.white.withValues(alpha: borderOpacity);
    }
    return Colors.white.withValues(alpha: borderOpacity * 2);
  }
}

/// Variante de GlassCard avec un header distinct.
///
/// ```dart
/// GlassCardWithHeader(
///   header: Text('Transactions récentes'),
///   trailing: TextButton(child: Text('Voir tout')),
///   child: TransactionList(),
/// )
/// ```
class GlassCardWithHeader extends StatelessWidget {
  const GlassCardWithHeader({
    required this.header, required this.child, super.key,
    this.trailing,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blurSigma = 10,
    this.onTap,
  });

  /// Widget du header (généralement un Text)
  final Widget header;

  /// Widget optionnel à droite du header
  final Widget? trailing;

  /// Contenu principal de la carte
  final Widget child;

  /// Padding interne
  final EdgeInsetsGeometry? padding;

  /// Margin externe
  final EdgeInsetsGeometry? margin;

  /// Rayon des bords arrondis
  final double borderRadius;

  /// Intensité du flou
  final double blurSigma;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      margin: margin,
      borderRadius: borderRadius,
      blurSigma: blurSigma,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                header,
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const _GlassDivider(),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  const _GlassDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (context.isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
