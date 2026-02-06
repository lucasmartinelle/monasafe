import 'package:flutter/material.dart';

import 'package:simpleflow/src/core/theme/app_colors.dart';

abstract final class AppTheme {
  static const String _fontFamilyPoppins = 'Poppins';
  static const String _fontFamilyInter = 'Inter';

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: _fontFamilyInter,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.process,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.processLight,
          onSurface: AppColors.textPrimaryLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        cardColor: AppColors.cardLight,
        dividerColor: AppColors.dividerLight,
        textTheme: _buildTextTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamilyPoppins,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            fontFamily: _fontFamilyInter,
            color: AppColors.textHintLight,
            fontSize: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedColor: AppColors.primaryLight,
          labelStyle: const TextStyle(
            fontFamily: _fontFamilyInter,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: _fontFamilyInter,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.process,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.processDark,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.dividerDark,
        textTheme: _buildTextTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamilyPoppins,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: _fontFamilyInter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            fontFamily: _fontFamilyInter,
            color: AppColors.textHintDark,
            fontSize: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.primaryDark,
          labelStyle: const TextStyle(
            fontFamily: _fontFamilyInter,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primaryColor = isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final secondaryColor = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }
}
