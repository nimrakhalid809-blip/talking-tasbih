import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Teal/Islamic green inspired
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Secondary - Gold/amber for accent
  static const Color secondary = Color(0xFFFFB300);
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFFF8F00);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  // High contrast
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastText = Color(0xFFFFFFFF);
  static const Color highContrastPrimary = Color(0xFF00E676);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFF9C4);
  static const Color warningDark = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Prayer specific
  static const Color fajr = Color(0xFF5C6BC0);
  static const Color sunrise = Color(0xFFFFCA28);
  static const Color dhuhr = Color(0xFFFFB74D);
  static const Color asr = Color(0xFFAB47BC);
  static const Color maghrib = Color(0xFFEF5350);
  static const Color isha = Color(0xFF37474F);

  // Qibla
  static const Color qiblaAligned = Color(0xFF00E676);
  static const Color qiblaNear = Color(0xFFFFEB3B);
  static const Color qiblaFar = Color(0xFFFF5722);
}

class AppTheme {
  static ThemeData darkTheme(Brightness brightness, {bool highContrast = false, bool extraLargeText = false, bool largeButtons = false}) {
    final textScale = extraLargeText ? 1.3 : 1.0;
    final buttonHeight = largeButtons ? 64.0 : 48.0;
    final fontSize = extraLargeText ? 18.0 : 14.0;
    final titleSize = extraLargeText ? 28.0 : 22.0;

    final primaryColor = highContrast ? AppColors.highContrastPrimary : AppColors.primary;
    final backgroundColor = highContrast ? AppColors.highContrastBackground : AppColors.backgroundDark;
    final surfaceColor = highContrast ? Color(0xFF1E1E1E) : AppColors.surfaceDark;
    final textColor = highContrast ? AppColors.highContrastText : AppColors.textPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textColor,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: extraLargeText ? 48.0 : 40.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: extraLargeText ? 20.0 : 16.0,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize + 2,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
        labelLarge: TextStyle(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, buttonHeight),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, buttonHeight),
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          textStyle: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(double.infinity, buttonHeight),
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highContrast ? BorderSide(color: textColor, width: 2) : BorderSide.none,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
        unselectedLabelStyle: TextStyle(fontSize: fontSize - 2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        thumbColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.3),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: textColor.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }

  static ThemeData lightTheme({bool highContrast = false, bool extraLargeText = false, bool largeButtons = false}) {
    final textScale = extraLargeText ? 1.3 : 1.0;
    final buttonHeight = largeButtons ? 64.0 : 48.0;
    final fontSize = extraLargeText ? 18.0 : 14.0;
    final titleSize = extraLargeText ? 28.0 : 22.0;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: extraLargeText ? 48.0 : 40.0,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        titleLarge: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontSize: extraLargeText ? 20.0 : 16.0,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize + 2,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize,
          color: AppColors.textPrimaryLight,
        ),
        labelLarge: TextStyle(
          fontSize: fontSize + 2,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, buttonHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
