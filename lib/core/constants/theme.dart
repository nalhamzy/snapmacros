import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildSnapMacrosTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.card,
      error: AppColors.danger,
    ),
    textTheme: textTheme.copyWith(
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.8),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
      titleLarge: GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, color: AppColors.textPrimary, height: 1.4),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: 0.2),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}
