import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/profile/dark_theme/dark_user_account_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/light_theme/light_user_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreenHelper {
  static Widget getScreen(
    BuildContext context,
    String name,
    String email,
    String profile_photo,
    String phone,
    String role,
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkMode = themeProvider.isDarkMode;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isDarkMode
              ? DarkUserAccountScreen(
                  key: const ValueKey('dark'), // 👈 Important for smooth switch
                  name: name,
                  email: email,
                  profile_photo: profile_photo,
                  phone: phone,
                  role: role,
                )
              : LightUserAccountScreen(
                  key: const ValueKey('light'), // 👈 Required too
                  name: name,
                  email: email,
                  profile_photo: profile_photo,
                  phone: phone,
                  role: role,
                ),
        );
      },
    );
  }
}
