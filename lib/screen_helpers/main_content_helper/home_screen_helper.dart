import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/light_theme/light_user_home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:provider/provider.dart';

class HomeScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkHomeScreen();
    } else {
      return const LightHomeScreen();
    }
  }
}
