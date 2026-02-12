import 'package:flutter/material.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';

/// Extension pour simplifier l'accès aux couleurs du thème selon le mode.
extension ThemeHelper on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get textHint =>
      isDark ? AppColors.textHintDark : AppColors.textHintLight;

  Color get cardColor =>
      isDark ? AppColors.cardDark : AppColors.cardLight;

  Color get backgroundColor =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

  Color get surfaceColor =>
      isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

  Color get dividerColor =>
      isDark ? AppColors.dividerDark : AppColors.dividerLight;
}
