import 'package:flutter/material.dart';
import 'package:w_utils/color_helper/color_helper.dart';

class WhiskrThemes {
  const WhiskrThemes._();

  static ThemeData lightTheme() {
    final Color scaffoldBackgroundColor = ColorHelper.lightThemeBackground.color;
    final ColorScheme baseColorScheme = ColorScheme.fromSeed(
      seedColor: ColorHelper.greenWeb.color,
      brightness: Brightness.light,
    );
    final ColorScheme colorScheme = baseColorScheme.copyWith(
      primary: ColorHelper.greenWeb.color,
      onPrimary: ColorHelper.white.color,
      secondary: ColorHelper.yellowWeb.color,
      onSecondary: ColorHelper.black.color,
      error: ColorHelper.redWeb.color,
      onError: ColorHelper.white.color,
      surface: ColorHelper.white.color,
      onSurface: ColorHelper.grey900.color,
      outline: ColorHelper.grey300.color,
      shadow: ColorHelper.black.color,
      scrim: ColorHelper.black.color,
      surfaceTint: ColorHelper.greenWeb.color,
    );

    final ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      canvasColor: colorScheme.surface,
      dividerColor: ColorHelper.grey200.color,
    );

    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorHelper.grey100.color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorHelper.grey900.color,
        contentTextStyle: TextStyle(color: ColorHelper.white.color),
      ),
    );
  }

  static ThemeData darkTheme() {
    final Color scaffoldBackgroundColor = ColorHelper.darkThemeBackground.color;
    final ColorScheme baseColorScheme = ColorScheme.fromSeed(
      seedColor: ColorHelper.green700.color,
      brightness: Brightness.dark,
    );
    final ColorScheme colorScheme = baseColorScheme.copyWith(
      primary: ColorHelper.green700.color,
      onPrimary: ColorHelper.white.color,
      secondary: ColorHelper.yellow500.color,
      onSecondary: ColorHelper.black.color,
      error: ColorHelper.red500.color,
      onError: ColorHelper.white.color,
      surface: ColorHelper.grey900.color,
      onSurface: ColorHelper.grey100.color,
      outline: ColorHelper.grey700.color,
      shadow: ColorHelper.black.color,
      scrim: ColorHelper.black.color,
      surfaceTint: ColorHelper.green700.color,
    );

    final ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      canvasColor: colorScheme.surface,
      dividerColor: ColorHelper.grey800.color,
    );

    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorHelper.grey800.color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorHelper.grey800.color,
        contentTextStyle: TextStyle(color: ColorHelper.grey100.color),
      ),
    );
  }
}

