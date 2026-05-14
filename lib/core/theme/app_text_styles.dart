import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get baseStyle => GoogleFonts.poppins(
        color: AppColors.textDark,
      );

  // Display
  static TextStyle get displayLarge => baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall => baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  // Headline
  static TextStyle get headlineLarge => baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // Title
  static TextStyle get titleLarge => baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleMedium => baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleSmall => baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  // Body
  static TextStyle get bodyLarge => baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  // Label
  static TextStyle get labelLarge => baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      );

  static TextStyle get labelMedium => baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      );

  static TextStyle get labelSmall => baseStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textGrey,
      );
}
