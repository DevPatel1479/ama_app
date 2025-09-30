import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/onboarding/dark_theme/dark_get_start_screen.dart';
import 'package:ama_legal_solutions/screens/onboarding/light_theme/light_get_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GetStartedScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkGetStartedScreen();
    } else {
      return const LightGetStartScreen();
    }
  }
}
