import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';

import 'package:ama_legal_solutions/screens/features/dark_theme/dark_payment_view_screen.dart';

import 'package:ama_legal_solutions/screens/features/light_theme/light_payment_view_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PaymentViewHelper extends StatelessWidget {
  const PaymentViewHelper({super.key});

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
          ? const DarkPaymentViewScreen(key: ValueKey('dark'))
          : const LightPaymentViewScreen(key: ValueKey('light')),
    );
  }
}
