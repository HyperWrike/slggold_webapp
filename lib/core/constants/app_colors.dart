import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (Onboarding / Heritage)
  static const Color royalPurple = Color(0xFF4A0E8F);
  static const Color deepPurple = Color(0xFF1E0A3C);
  static const Color ambientPurple = Color(0xFF3D1A7A);

  // Gold Variants
  static const Color goldPrimary = Color(0xFFF5C842);
  static const Color goldDark = Color(0xFFC8860A);
  static const Color goldLight = Color(0xFFFFD700);

  // Primary (HTML design)
  static const Color primary = Color(0xFF795900);
  static const Color primaryContainer = Color(0xFFD4A017);
  static const Color primaryFixed = Color(0xFFFFDFA0);
  static const Color primaryFixedDim = Color(0xFFF6BE39);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF503A00);
  static const Color inversePrimary = Color(0xFFF6BE39);

  // Silver Variants
  static const Color silverPrimary = Color(0xFFC0C0C0);
  static const Color silverDark = Color(0xFF707070);
  static const Color silver = silverPrimary;

  // Surface Colors (Main App / HTML design)
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color surfaceDim = Color(0xFFDADADA);
  static const Color surfaceBright = Color(0xFFF9F9F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF4F4634);
  static const Color textWhite = Color(0xFFFFFFFF);

  // State Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF16A34A);
  static const Color emerald = Color(0xFF059669);

  // Secondary (HTML design)
  static const Color secondary = Color(0xFF685589);
  static const Color secondaryContainer = Color(0xFFD9C2FE);
  static const Color secondaryFixed = Color(0xFFECDCFF);
  static const Color secondaryFixedDim = Color(0xFFD4BCF8);

  // Outline
  static const Color outline = Color(0xFF817662);
  static const Color outlineVariant = Color(0xFFD3C5AE);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldPrimary, goldDark],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [silverPrimary, silverDark],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [goldPrimary, goldDark],
  );
}
