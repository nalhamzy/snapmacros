import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0F1114);
  static const bgElevated = Color(0xFF181B20);
  static const card = Color(0xFF1E2128);
  static const border = Color(0xFF2A2E36);
  static const textPrimary = Color(0xFFF5F6F8);
  static const textSecondary = Color(0xFF9FA4B0);
  static const textMuted = Color(0xFF5E6470);

  static const accent = Color(0xFF00D980);       // signature green
  static const accent2 = Color(0xFF5C9BFF);      // calm blue
  static const accentProtein = Color(0xFFFF5C8A);
  static const accentCarbs = Color(0xFFFFC85C);
  static const accentFat = Color(0xFF8B5CFF);

  static const gold = Color(0xFFFFC75F);
  static const success = Color(0xFF00D980);
  static const warn = Color(0xFFFFB547);
  static const danger = Color(0xFFFF5A5A);

  static const gradientMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D980), Color(0xFF5C9BFF)],
  );
  static const gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC75F), Color(0xFFFF8A3D)],
  );
}
