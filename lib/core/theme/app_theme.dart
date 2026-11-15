import 'package:flutter/material.dart';

class AppTheme {
  // Obsidian IDE Dark Theme
  static ThemeData darkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF10B981), // Emerald 500
      onPrimary: Color(0xFF022C22),
      primaryContainer: Color(0xFF064E3B),
      onPrimaryContainer: Color(0xFF6EE7B7),
      secondary: Color(0xFFF59E0B), // Amber Gold
      onSecondary: Color(0xFF451A03),
      secondaryContainer: Color(0xFF78350F),
      onSecondaryContainer: Color(0xFFFCD34D),
      tertiary: Color(0xFF38BDF8), // Cyan/Sky
      onTertiary: Color(0xFF082F49),
      error: Color(0xFFEF4444), // Crimson
      onError: Color(0xFF450A0A),
      surface: Color(0xFF0F172A), // Dark Slate/Obsidian
      onSurface: Color(0xFFF1F5F9), // Light Slate
      surfaceContainer: Color(0xFF1E293B), // Slate 800
      surfaceContainerHighest: Color(0xFF334155), // Slate 700
      surfaceContainerLow: Color(0xFF131D2E),
      onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainer,
      dividerColor: colorScheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }

  // Crisp Academic Light Theme
  static ThemeData lightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF047857), // Deep Emerald
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: Color(0xFF064E3B),
      secondary: Color(0xFFD97706), // Academic Amber
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF78350F),
      tertiary: Color(0xFF0284C7), // Academic Sky
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFF8FAFC), // Crisp Clean Slate
      onSurface: Color(0xFF0F172A),
      surfaceContainer: Color(0xFFFFFFFF), // Pure White Card
      surfaceContainerHighest: Color(0xFFE2E8F0),
      surfaceContainerLow: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainer,
      dividerColor: colorScheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }
}
