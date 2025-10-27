import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';
  bool _isDarkMode;

  ThemeProvider._(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  /// ✅ Factory initializer to load saved theme from SharedPreferences
  static Future<ThemeProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTheme = prefs.getBool(_themeKey);
    final systemDefault =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    return ThemeProvider._(storedTheme ?? systemDefault);
  }

  /// ✅ Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// ✅ Explicitly set theme (dark/light)
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    }
  }
}
