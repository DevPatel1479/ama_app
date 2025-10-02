import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/features/profile/dark_theme/dark_user_account_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/light_theme/light_user_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreenHelper {
  /// Returns the appropriate Get Started screen based on theme
  static Widget getScreen(
    BuildContext context,
    String name,
    String email,
    String profile_photo,
    String phone,
    String role,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (isDarkMode) {
      return DarkUserAccountScreen(
        name: name,
        email: email,
        profile_photo: profile_photo,
        phone: phone,
        role: role,
      );
    } else {
      return const LightUserAccountScreen();
    }
  }
}
