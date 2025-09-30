import 'package:ama_legal_solutions/provider/auth/signup_screen_provider.dart';

import 'package:ama_legal_solutions/screen_helpers/auth_helper/login_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/auth_helper/signup_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/advocate_casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/ama_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/home_screen_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/raise_query_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/services_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/onboarding_helper/get_started_helper.dart';

import 'package:ama_legal_solutions/screens/onboarding/splash_screen.dart';

import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';

import 'package:ama_legal_solutions/screen_helpers/portfolio_helper/portfolio_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/profile_helper/profile_helper.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppPathsForScreen.getStartedPath,
  routes: [
    GoRoute(
      path: AppPathsForScreen.splashPath,
      name: AppScreenNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppPathsForScreen.userHomePath,
      name: AppScreenNames.userHome,
      builder: (context, state) => HomeScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.getStartedPath,
      name: AppScreenNames.getStarted,
      builder: (context, state) {
        return GetStartedScreenHelper.getScreen(context);
      },
    ),

    GoRoute(
      path: AppPathsForScreen.signUpPath,
      name: AppScreenNames.signUp,
      builder: (context, state) {
        // Wrap the SignUpScreen with ChangeNotifierProvider
        return ChangeNotifierProvider(
          create: (_) => SignupProvider(),
          child: SignupScreenHelper.getScreen(context),
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.logInPath,
      name: AppScreenNames.logIn,
      builder: (context, state) {
        // return DarkLoginScreen();
        return LoginScreenHelper.getScreen(context);
      },
    ),
    GoRoute(
      path: AppPathsForScreen.userAccountPath,
      name: AppScreenNames.userAccount,
      builder: (context, state) => ProfileScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.portfolioPath,
      name: AppScreenNames.portfolio,
      builder: (context, state) => PortfolioSreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.amaPath,
      name: AppScreenNames.ama,
      builder: (context, state) => AmaScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.caseDeskPath,
      name: AppScreenNames.caseDesk,
      builder: (context, state) => CaseDeskScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.advocateCaseDeskPath,
      name: AppScreenNames.advocateCaseDesk,
      builder: (context, state) =>
          AdvocateCasedeskScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.amaServicesPath,
      name: AppScreenNames.amaServices,
      builder: (context, state) => ServicesScreenHelper.getScreen(context),
    ),
    GoRoute(
      path: AppPathsForScreen.raiseQueryPath,
      name: AppScreenNames.raiseQuery,
      builder: (context, state) => RaiseQueryScreenHelper.getScreen(context),
    ),
  ],
);
