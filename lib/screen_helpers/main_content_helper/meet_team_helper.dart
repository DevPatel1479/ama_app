import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/screens/features/dark_theme/dark_meet_team_screen.dart';

import 'package:ama_legal_solutions/screens/features/light_theme/light_meet_team_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class MeetTeamHelper extends StatelessWidget {
  const MeetTeamHelper({super.key});

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
          ? const DarkMeetTeamScreen(key: ValueKey('dark'))
          : const LightMeetTeamScreen(key: ValueKey('light')),
    );
  }
}
