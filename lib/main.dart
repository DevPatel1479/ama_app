import 'package:ama_legal_solutions/custom_widgets/bottom_navigation.dart';
import 'package:ama_legal_solutions/screens/auth/login_screen.dart';
import 'package:ama_legal_solutions/screens/auth/signup_screen.dart';
import 'package:ama_legal_solutions/screens/features/ama_screen.dart';
import 'package:ama_legal_solutions/screens/features/casedesk_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/portfolio_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/user_account_screen.dart';
import 'package:ama_legal_solutions/screens/features/raise_query_screen.dart';
import 'package:ama_legal_solutions/screens/features/services_screen.dart';
import 'package:ama_legal_solutions/screens/onboarding/get_start_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/user_home_screen.dart';
import 'package:ama_legal_solutions/screens/routes/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routerConfig: appRouter,
    );
  }
}
