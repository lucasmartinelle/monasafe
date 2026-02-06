import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Colors - Teal foncé (sidebar, boutons principaux)
  static const Color primary = Color(0xFF1B5E5A);
  static const Color primaryLight = Color(0xFF4A8B87);
  static const Color primaryDark = Color(0xFF0D3D3A);

  // Accent Color - Orange/Corail (CTA, actions)
  static const Color process = Color(0xFFE87B4D);
  static const Color processLight = Color(0xFFF4A57D);
  static const Color processDark = Color(0xFFD15A2A);

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFE8E8E8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textHintDark = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Divider & Border
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // Overlay
  static const Color overlay = Color(0x80000000);
}
