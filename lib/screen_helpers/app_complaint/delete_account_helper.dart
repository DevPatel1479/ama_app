import 'package:ama_legal_solutions/app_complaint_details/dark_theme/dark_delete_account_screen.dart';
import 'package:ama_legal_solutions/app_complaint_details/light_theme/light_delete_account_screen.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreenHelper {
  /// Returns the appropriate Privacy screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return const DarkDeleteAccountScreen();
    } else {
      return const LightDeleteAccountScreen();
    }
  }
}
