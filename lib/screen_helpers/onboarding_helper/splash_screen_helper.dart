import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/onboarding/dark_theme/dark_splash_screen.dart';

import 'package:ama_legal_solutions/screens/onboarding/light_theme/light_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkSplashScreen();
    } else {
      return const LightSplashScreen();
    }
  }
}
