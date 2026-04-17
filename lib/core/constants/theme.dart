import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildSnapMacrosTheme({bool useSystemFonts = false}) {
  final base = ThemeData.dark(useMaterial3: true);

  const bodyFamily = 'Inter';
  const displayFamily = 'SpaceGrotesk';

  TextStyle body(double size,
          {FontWeight? weight,
          Color? color,
          double height = 1.4,
          double? letterSpacing}) =>
      TextStyle(
        fontFamily: useSystemFonts ? null : bodyFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: letterSpacing,
      );

  TextStyle display(double size,
          {FontWeight weight = FontWeight.w700,
          double letterSpacing = -0.8,
          Color? color}) =>
      TextStyle(
        fontFamily: useSystemFonts ? null : displayFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        letterSpacing: letterSpacing,
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.card,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.copyWith(
      displayMedium: display(32),
      headlineMedium: display(22, weight: FontWeight.w600, letterSpacing: 0),
      titleLarge: body(17, weight: FontWeight.w600),
      bodyLarge: body(15),
      bodyMedium: body(13, color: AppColors.textSecondary),
      labelLarge: body(14, weight: FontWeight.w600, letterSpacing: 0.2),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: display(20, weight: FontWeight.w700, letterSpacing: 0),
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
