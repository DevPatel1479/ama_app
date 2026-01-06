import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/delete_account_request/delete_account_request_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountRequestScreenHelper {
  /// Returns the appropriate Privacy screen based on theme
  static Widget getScreen(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return DeleteAccountRequestScreen(isDark: isDarkMode);
  }
}
