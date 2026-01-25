import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';

/// Ligne avec icône, label, sous-titre optionnel et widget trailing.
///
/// Pattern très répandu dans l'app pour les listes et tiles.
///
/// ```dart
/// IconLabelTile(
///   icon: Icons.calendar_today,
///   iconColor: AppColors.primary,
///   label: 'Date',
///   subtitle: 'Lundi 15 janvier 2024',
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => showDatePicker(...),
/// )
/// ```
class IconLabelTile extends StatelessWidget {
  const IconLabelTile({
    required this.label, super.key,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconBackgroundColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.iconSize = 20,
    this.iconContainerSize = 36,
    this.showIconContainer = false,
    this.iconContainerBorderRadius = 8,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');

  /// Icône à afficher (utilisée si iconWidget n'est pas fourni)
  final IconData? icon;

  /// Widget personnalisé pour l'icône (prioritaire sur icon)
  final Widget? iconWidget;

  /// Couleur de l'icône
  final Color? iconColor;

  /// Couleur de fond du conteneur d'icône (si showIconContainer est true)
  final Color? iconBackgroundColor;

  /// Texte principal
  final String label;

  /// Texte secondaire (optionnel)
  final String? subtitle;

  /// Widget à droite (optionnel)
  final Widget? trailing;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Padding du tile
  final EdgeInsetsGeometry? padding;

  /// Taille de l'icône
  final double iconSize;

  /// Taille du conteneur d'icône
  final double iconContainerSize;

  /// Affiche l'icône dans un conteneur coloré
  final bool showIconContainer;

  /// Border radius du conteneur d'icône
  final double iconContainerBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final defaultIconColor = iconColor ?? AppColors.primary;

    var iconContent = iconWidget ??
        Icon(
          icon,
          size: iconSize,
          color: defaultIconColor,
        );

    if (showIconContainer) {
      final bgColor = iconBackgroundColor ?? defaultIconColor.withValues(alpha: 0.15);
      iconContent = Container(
        width: iconContainerSize,
        height: iconContainerSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(iconContainerBorderRadius),
        ),
        child: Center(child: iconContent),
      );
    }

    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          iconContent,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption(color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}

/// Variante pour les transactions avec montant coloré.
///
/// ```dart
/// TransactionTileContent(
///   icon: Icons.restaurant,
///   iconColor: Colors.orange,
///   label: 'Alimentation',
///   subtitle: '15 jan - Supermarché',
///   amount: -50.00,
///   currency: 'EUR',
/// )
/// ```
class TransactionTileContent extends StatelessWidget {
  const TransactionTileContent({
    required this.icon, required this.iconColor, required this.label, required this.amount, super.key,
    this.subtitle,
    this.currency = 'EUR',
    this.onTap,
    this.padding,
  });

  /// Icône de la catégorie
  final IconData icon;

  /// Couleur de la catégorie
  final Color iconColor;

  /// Nom de la catégorie
  final String label;

  /// Sous-titre (date, note, etc.)
  final String? subtitle;

  /// Montant de la transaction
  final double amount;

  /// Code de la devise
  final String currency;

  /// Callback appelé lors du tap
  final VoidCallback? onTap;

  /// Padding du tile
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isExpense = amount < 0;
    final amountColor = isExpense ? AppColors.error : AppColors.success;
    final sign = isExpense ? '' : '+';
    final displayAmount = '$sign${amount.abs().toStringAsFixed(2)} ${_getCurrencySymbol(currency)}';

    return IconLabelTile(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconColor.withValues(alpha: 0.15),
      showIconContainer: true,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
      padding: padding,
      trailing: Text(
        displayAmount,
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    return switch (currency) {
      'EUR' => '\u20AC',
      'USD' => r'$',
      'GBP' => '\u00A3',
      'JPY' => '\u00A5',
      'CHF' => 'CHF',
      _ => currency,
    };
  }
}
