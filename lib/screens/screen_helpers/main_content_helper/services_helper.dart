import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_services_screen.dart';
import 'package:ama_legal_solutions/screens/features/light_theme/light_services_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServicesScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkServicesScreen();
    } else {
      return const LightServicesScreen();
    }
  }
}
