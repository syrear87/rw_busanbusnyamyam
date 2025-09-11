import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      fontFamily: 'Dongle',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Dongle'),
        displayMedium: TextStyle(fontFamily: 'Dongle'),
        displaySmall: TextStyle(fontFamily: 'Dongle'),
        headlineLarge: TextStyle(fontFamily: 'Dongle'),
        headlineMedium: TextStyle(fontFamily: 'Dongle'),
        headlineSmall: TextStyle(fontFamily: 'Dongle'),
        titleLarge: TextStyle(fontFamily: 'Dongle'),
        titleMedium: TextStyle(fontFamily: 'Dongle'),
        titleSmall: TextStyle(fontFamily: 'Dongle'),
        bodyLarge: TextStyle(fontFamily: 'Dongle'),
        bodyMedium: TextStyle(fontFamily: 'Dongle'),
        bodySmall: TextStyle(fontFamily: 'Dongle'),
        labelLarge: TextStyle(fontFamily: 'Dongle'),
        labelMedium: TextStyle(fontFamily: 'Dongle'),
        labelSmall: TextStyle(fontFamily: 'Dongle'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.accent,
        titleTextStyle: TextStyle(
          fontFamily: 'Dongle',
          fontSize: 28,
          color: AppColors.accent,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.accent),
      dividerTheme: const DividerThemeData(
        color: AppColors.accent,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.accent, width: 1),
        ),
        margin: const EdgeInsets.all(12),
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.accent, width: 1),
        selectedColor: AppColors.accent,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(fontFamily: 'Dongle', color: AppColors.accent),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Dongle',
          color: Colors.white,
        ),
        showCheckmark: false,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: StadiumBorder(),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: AppColors.background,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Dongle',
            fontSize: 18,
            color: AppColors.accent,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: AppColors.accent),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: AppColors.text,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        background: AppColors.background,
        primary: AppColors.accent,
        onPrimary: Colors.white,
      ),
    );
  }
}
