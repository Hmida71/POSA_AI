import 'package:flutter/material.dart';
import 'package:posa_ai_app/utils/constants.dart';

class ThemeUtils {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.colorApp,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      onError: Colors.white,
    ),
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.colorApp,
      secondary: AppColors.accent,
      surface: Color(0xFF1E1E1E),
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    primarySwatch: AppColors.primarySwatch,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Roboto',
  );
}
