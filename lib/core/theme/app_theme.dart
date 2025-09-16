import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivoryBase,
      primaryColor: AppColors.primarySage,
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
        backgroundColor: AppColors.ivoryBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.primarySage,
        titleTextStyle: TextStyle(
          fontFamily: 'Dongle',
          fontSize: 31,
          color: AppColors.primarySage,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.primarySage),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.ivorySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSage, width: 0.5),
        ),
        margin: const EdgeInsets.all(12),
        shadowColor: const Color(0x14000000), // 반투명 검정
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.borderSage, width: 1),
        selectedColor: AppColors.primarySage,
        backgroundColor: AppColors.ivorySurface,
        labelStyle: TextStyle(fontFamily: 'Dongle', color: AppColors.textBody),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Dongle',
          color: AppColors.onPrimary,
        ),
        showCheckmark: false,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: StadiumBorder(),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: AppColors.ivoryBase,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Dongle',
            fontSize: 21,
            color: AppColors.primarySage,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: AppColors.primarySage),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primarySage,
        textColor: AppColors.textBody,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primarySage,
        brightness: Brightness.light,
        background: AppColors.ivoryBase,
        surface: AppColors.ivorySurface,
        primary: AppColors.primarySage,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryContainer,
        onSecondary: AppColors.textBody,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        onBackground: AppColors.textBody,
        onSurface: AppColors.textBody,
      ),
    );
  }
}
