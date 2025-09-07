import 'package:ama_legal_solutions/provider/auth/signup_screen_provider.dart';
import 'package:ama_legal_solutions/screens/auth/login_screen.dart';
import 'package:ama_legal_solutions/screens/auth/signup_screen.dart';
import 'package:ama_legal_solutions/screens/features/ama_screen.dart';
import 'package:ama_legal_solutions/screens/features/casedesk_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/portfolio_screen.dart';
import 'package:ama_legal_solutions/screens/features/profile/user_account_screen.dart';
import 'package:ama_legal_solutions/screens/features/raise_query_screen.dart';
import 'package:ama_legal_solutions/screens/features/services_screen.dart';
import 'package:ama_legal_solutions/screens/onboarding/get_start_screen.dart';
import 'package:ama_legal_solutions/screens/onboarding/splash_screen.dart';
import 'package:ama_legal_solutions/screens/roles/user/user_home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/userHome',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/userHome',
      name: 'user_home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/getStarted',
      name: 'get_started',
      builder: (context, state) => const GetStartedScreen(),
    ),

    GoRoute(
      path: '/signUp',
      name: 'sign_up',
      builder: (context, state) {
        // Wrap the SignUpScreen with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (_) => SignupProvider(),
          child: SignUpScreen(),
        );
      },
    ),
    GoRoute(
      path: '/logIn',
      name: 'log_in',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/userAccount',
      name: 'user_account',
      builder: (context, state) => const UserAccountScreen(),
    ),
    GoRoute(
      path: '/portfolio',
      name: 'portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: '/ama',
      name: 'ama',
      builder: (context, state) => const AmaScreen(),
    ),
    GoRoute(
      path: '/caseDesk',
      name: 'case_Desk',
      builder: (context, state) => const MyCasedeskScreen(),
    ),
    GoRoute(
      path: '/amaServices',
      name: 'ama_services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/raiseQuery',
      name: 'raise_query',
      builder: (context, state) => const RaiseQueryScreen(),
    ),
  ],
);
