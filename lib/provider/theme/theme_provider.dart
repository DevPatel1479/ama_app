import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider({bool? isDarkMode})
    : _isDarkMode =
          isDarkMode ??
          PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}
