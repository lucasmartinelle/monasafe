import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const String _fontFamilyPoppins = 'Poppins';
  static const String _fontFamilyInter = 'Inter';

  // Headings - Poppins
  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle h4({Color? color}) => TextStyle(
        fontFamily: _fontFamilyPoppins,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  // Body Text - Inter
  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // Labels & Buttons - Inter
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  // Caption - Inter
  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  // Button Text
  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: _fontFamilyInter,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
      );
}
