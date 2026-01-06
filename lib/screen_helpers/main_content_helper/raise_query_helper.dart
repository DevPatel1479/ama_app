import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_raise_query_screen.dart';

import 'package:ama_legal_solutions/screens/features/light_theme/light_raise_query_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RaiseQueryScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(
    BuildContext context,
    bool questionPosting,
    bool isFilingDispute,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return DarkRaiseQueryScreen(
        isQuestionPosting: questionPosting,
        isFilingDispute: isFilingDispute,
      );
    } else {
      return LightRaiseQueryScreen(
        isQuestionPosting: questionPosting,
        isFilingDispute: isFilingDispute,
      );
    }
  }
}
