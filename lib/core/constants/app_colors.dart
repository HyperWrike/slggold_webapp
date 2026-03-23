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

  // Silver Variants
  static const Color silverPrimary = Color(0xFFC0C0C0);
  static const Color silverDark = Color(0xFF707070);
  static const Color silver = silverPrimary;

  // Surface Colors (Main App)
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4F4634);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // State Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF16A34A);

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
}
