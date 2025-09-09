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
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppPathsForScreen.splashPath,
  routes: [
    GoRoute(
      path: AppPathsForScreen.splashPath,
      name: AppScreenNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppPathsForScreen.userHomePath,
      name: AppScreenNames.userHome,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.getStartedPath,
      name: AppScreenNames.getStarted,
      builder: (context, state) => const GetStartedScreen(),
    ),

    GoRoute(
      path: AppPathsForScreen.signUpPath,
      name: AppScreenNames.signUp,
      builder: (context, state) {
        // Wrap the SignUpScreen with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (_) => SignupProvider(),
          child: SignUpScreen(),
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.logInPath,
      name: AppScreenNames.logIn,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.userAccountPath,
      name: AppScreenNames.userAccount,
      builder: (context, state) => const UserAccountScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.portfolioPath,
      name: AppScreenNames.portfolio,
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.amaPath,
      name: AppScreenNames.ama,
      builder: (context, state) => const AmaScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.caseDeskPath,
      name: AppScreenNames.caseDesk,
      builder: (context, state) => const MyCasedeskScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.amaServicesPath,
      name: AppScreenNames.amaServices,
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: AppPathsForScreen.raiseQueryPath,
      name: AppScreenNames.raiseQuery,
      builder: (context, state) => const RaiseQueryScreen(),
    ),
  ],
);
