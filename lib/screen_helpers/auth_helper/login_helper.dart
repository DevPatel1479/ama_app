import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_login_screen.dart';

import 'package:ama_legal_solutions/screens/auth/light_theme/light_login_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkLoginScreen();
    } else {
      return const LightLoginScreen();
    }
  }
}
