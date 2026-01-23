import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_live_case_status_screen.dart';

import 'package:ama_legal_solutions/screens/features/light_theme/light_live_case_status_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LiveCaseStatusHelper extends StatelessWidget {
  const LiveCaseStatusHelper({super.key});

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
          ? const DarkLiveCaseStatusScreen(key: ValueKey('dark'))
          : const LightLiveCaseStatusScreen(key: ValueKey('light')),
    );
  }
}
