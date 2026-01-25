import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';

/// Variantes disponibles pour AppButton
enum AppButtonVariant {
  /// Bouton plein avec fond coloré (CTA principal)
  primary,

  /// Bouton avec bordure, fond transparent
  secondary,

  /// Bouton texte uniquement, sans bordure ni fond
  ghost,
}

/// Tailles disponibles pour AppButton
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Bouton réutilisable avec variantes Primary, Secondary et Ghost.
///
/// Supporte les états: Enabled, Disabled et Loading (avec spinner).
///
/// ```dart
/// AppButton(
///   label: 'Sauvegarder',
///   onPressed: () => save(),
///   variant: AppButtonVariant.primary,
///   isLoading: isSaving,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label, super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.fullWidth = false,
  });

  /// Texte affiché dans le bouton
  final String label;

  /// Callback appelé lors du tap. Si null, le bouton est désactivé.
  final VoidCallback? onPressed;

  /// Variante visuelle du bouton
  final AppButtonVariant variant;

  /// Taille du bouton
  final AppButtonSize size;

  /// Affiche un spinner et désactive le bouton
  final bool isLoading;

  /// Icône optionnelle
  final IconData? icon;

  /// Position de l'icône
  final IconPosition iconPosition;

  /// Si true, le bouton prend toute la largeur disponible
  final bool fullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: switch (variant) {
        AppButtonVariant.primary => _buildPrimaryButton(isDark),
        AppButtonVariant.secondary => _buildSecondaryButton(isDark),
        AppButtonVariant.ghost => _buildGhostButton(isDark),
      },
    );
  }

  Widget _buildPrimaryButton(bool isDark) {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: isDark
            ? AppColors.primaryDark.withValues(alpha: 0.5)
            : AppColors.primaryLight.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: _buildContent(Colors.white),
    );
  }

  Widget _buildSecondaryButton(bool isDark) {
    final borderColor = _isEnabled
        ? AppColors.primary
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final textColor = _isEnabled
        ? AppColors.primary
        : (isDark ? AppColors.textHintDark : AppColors.textHintLight);

    return OutlinedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: borderColor, width: 1.5),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: _buildContent(textColor),
    );
  }

  Widget _buildGhostButton(bool isDark) {
    final textColor = _isEnabled
        ? AppColors.primary
        : (isDark ? AppColors.textHintDark : AppColors.textHintLight);

    return TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: _buildContent(textColor),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: _getSpinnerSize(),
        height: _getSpinnerSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: AppTextStyles.button(color: color),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(icon, size: _getIconSize(), color: color);
    final spacing = SizedBox(width: _getIconSpacing());

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, spacing, textWidget]
          : [textWidget, spacing, iconWidget],
    );
  }

  double _getHeight() {
    return switch (size) {
      AppButtonSize.small => 36,
      AppButtonSize.medium => 44,
      AppButtonSize.large => 52,
    };
  }

  EdgeInsets _getPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 32),
    };
  }

  double _getBorderRadius() {
    return switch (size) {
      AppButtonSize.small => 8,
      AppButtonSize.medium => 12,
      AppButtonSize.large => 16,
    };
  }

  double _getSpinnerSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }

  double _getIconSpacing() {
    return switch (size) {
      AppButtonSize.small => 6,
      AppButtonSize.medium => 8,
      AppButtonSize.large => 10,
    };
  }
}

/// Position de l'icône dans le bouton
enum IconPosition {
  left,
  right,
}
