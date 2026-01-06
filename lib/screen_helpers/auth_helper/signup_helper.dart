import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/auth/dark_theme/dark_signup_screen.dart';
import 'package:ama_legal_solutions/screens/auth/light_theme/light_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkSignupScreen();
    } else {
      return const LightSignupScreen();
    }
  }
}
