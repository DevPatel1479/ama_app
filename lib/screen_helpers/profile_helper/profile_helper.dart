import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/features/profile/dark_theme/dark_user_account_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/light_theme/light_user_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkUserAccountScreen();
    } else {
      return const LightUserAccountScreen();
    }
  }
}
