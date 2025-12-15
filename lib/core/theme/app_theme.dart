import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        brightness: Brightness.light,
        primary: AppConfig.primaryColor,
        secondary: AppConfig.secondaryColor,
        error: AppConfig.errorColor,
        surface: AppConfig.surfaceColor,
      ),
      scaffoldBackgroundColor: AppConfig.backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppConfig.backgroundColor,
        foregroundColor: AppConfig.textPrimaryColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppConfig.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppConfig.surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConfig.textPrimaryColor),
        displayMedium: TextStyle(color: AppConfig.textPrimaryColor),
        displaySmall: TextStyle(color: AppConfig.textPrimaryColor),
        headlineLarge: TextStyle(color: AppConfig.textPrimaryColor),
        headlineMedium: TextStyle(color: AppConfig.textPrimaryColor),
        headlineSmall: TextStyle(color: AppConfig.textPrimaryColor),
        titleLarge: TextStyle(color: AppConfig.textPrimaryColor),
        titleMedium: TextStyle(color: AppConfig.textPrimaryColor),
        titleSmall: TextStyle(color: AppConfig.textPrimaryColor),
        bodyLarge: TextStyle(color: AppConfig.textPrimaryColor),
        bodyMedium: TextStyle(color: AppConfig.textPrimaryColor),
        bodySmall: TextStyle(color: AppConfig.textSecondaryColor),
        labelLarge: TextStyle(color: AppConfig.textPrimaryColor),
        labelMedium: TextStyle(color: AppConfig.textSecondaryColor),
        labelSmall: TextStyle(color: AppConfig.textSecondaryColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.primaryColor,
        brightness: Brightness.dark,
        primary: AppConfig.primaryLightColor,
        secondary: AppConfig.secondaryColor,
        error: AppConfig.errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF121212),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
