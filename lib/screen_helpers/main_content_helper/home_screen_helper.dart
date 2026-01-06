import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/roles/user/dark_theme/dark_user_home_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/light_theme/light_user_home_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class HomeScreenHelper extends StatelessWidget {
  const HomeScreenHelper({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: isDark
          ? const DarkHomeScreen(key: ValueKey('dark'))
          : const LightHomeScreen(key: ValueKey('light')),
    );
  }
}
