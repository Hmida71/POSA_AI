import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor primarySwatch = Colors.blue;
  static const Color primary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color text = Color(0xFF000000);
  static const Color textLight = Color(0xFF757575);

  // Theme-specific background colors
  static const Color darkBackground = Color(0xFF1F1F1F);
  static const Color lightBackground = Color(0xFFF5F5F5);
  // Primary Cyan Color Swatch
  static const MaterialColor colorApp = MaterialColor(
    0xFF00BCD4, // Cyan base color
    {
      50: Color(0xFFE0F8FF), // Lightest cyan
      100: Color(0xFFB3ECFF),
      200: Color(0xFF80DEEA),
      300: Color(0xFF4DD0E1),
      400: Color(0xFF26C6DA),
      500: Color(0xFF00BCD4), // Base cyan color
      600: Color(0xFF00ACC1),
      700: Color(0xFF0097A7),
      800: Color(0xFF00838F),
      900: Color(0xFF006064), // Darkest cyan
    },
  );
}

class AppConstants {
  // API Constants
  static const String packageName = 'com.posaaibytm71.posaai';
  static const String supabaseUrl = 'https://vfcklwgmmxthktbbrxan.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmY2tsd2dtbXh0aGt0YmJyeGFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2OTA0NzAsImV4cCI6MjA2NDI2NjQ3MH0.6gbvdveg6fi9sUf_ncY8hfWpNbJ7vX5jj15aHAPerrM';

  /// Web Client ID that you registered with Google Cloud.
  static const webClientId =
      '167948678986-6f8e21qdnftovhmn722m9jfub4tuhmeq.apps.googleusercontent.com';

  /// iOS Client ID that you registered with Google Cloud.
  static const iosClientId = 'my-ios.apps.googleusercontent.com';

  // Storage Constants
  static const String productImagesBucket = 'images';

  // Role Constants
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 500;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Animation Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
