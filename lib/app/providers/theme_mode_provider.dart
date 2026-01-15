import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends ChangeNotifier {
  static const String _storageKey = 'selected_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeModeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? rawValue = preferences.getString(_storageKey);
    final ThemeMode resolvedThemeMode = _parseThemeMode(rawValue) ?? ThemeMode.system;

    if (resolvedThemeMode == _themeMode) {
      return;
    }

    _themeMode = resolvedThemeMode;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == _themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, _serializeThemeMode(themeMode));
  }

  static ThemeMode? _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _serializeThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

