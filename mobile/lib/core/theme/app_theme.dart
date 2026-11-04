import 'package:flutter/material.dart';

class AppColors {
  static const terracotta = Color(0xFFA44B2D);
  static const terracottaDark = Color(0xFF8A3B21);
  static const moss = Color(0xFF5B7553);
  static const mossDark = Color(0xFF47603F);
  static const cream = Color(0xFFFDF8F1);
  static const creamDark = Color(0xFFF3E8D8);
  static const bark = Color(0xFF3E2F28);
  static const barkLight = Color(0xFF7A6A61);
  static const sand = Color(0xFFE8DCC8);
  static const amber = Color(0xFFC17A28);
  static const errorRed = Color(0xFFB3261E);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.terracotta,
    primary: AppColors.terracotta,
    onPrimary: Colors.white,
    secondary: AppColors.moss,
    onSecondary: Colors.white,
    surface: AppColors.cream,
    onSurface: AppColors.bark,
    error: AppColors.errorRed,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.bark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.bark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.bark,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.bark),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.bark),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.barkLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.bark,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.terracotta,
        side: const BorderSide(color: AppColors.terracotta),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.sand),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.creamDark,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.moss,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
