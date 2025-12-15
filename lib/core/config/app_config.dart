import 'package:flutter/material.dart';

/// Centralized app configuration
/// Change colors, app name, and logo from here
class AppConfig {
  // App Identity
  static const String appName = 'monex';
  static const String appDisplayName = 'monex';

  // Logo Configuration
  static const String logoPath = 'assets/images/logo.png';
  static const String logoPlaceholderPath =
      'assets/images/logo_placeholder.png';

  // Primary Colors - Change these to update the entire app theme
  static const Color primaryColor = Color(0xFF4CBB17); // Blue color from design
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFFF9800);

  // Background Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Error and Success Colors
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);

  // Splash Screen Configuration
  static const Color splashBackgroundColor = Color(0xFFFFFFFF);
  static const Duration splashDuration = Duration(seconds: 2);
}
