import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/features/profile/dark_theme/dark_portfolio_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/light_theme/light_portfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PortfolioSreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(BuildContext context, String userRole) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return DarkPortfolioScreen(userRole: userRole);
    } else {
      return LightPortfolioScreen(userRole: userRole);
    }
  }
}
