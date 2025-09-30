import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_advocate_casedesk_screen.dart';

import 'package:ama_legal_solutions/screens/features/light_theme/light_advocate_casedesk_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvocateCasedeskScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkAdvocateCasedeskScreen();
    } else {
      return const LightAdvocateCasedeskScreen();
    }
  }
}
