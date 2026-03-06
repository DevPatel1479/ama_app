import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/features/dark_theme/dark_ama_leads_screen.dart';
import 'package:ama_legal_solutions/screens/features/light_theme/light_ama_leads_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmaLeadsScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context, String name) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return DarkAmaLeadsScreen(name: name, key: ValueKey('dark'));
    } else {
      return LightAmaLeadsScreen(name: name, key: ValueKey('light'));
    }
  }
}
