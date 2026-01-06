import 'dart:io';

import 'package:ama_legal_solutions/provider/auth/login_screen_provider.dart';
import 'package:ama_legal_solutions/provider/auth/signup_screen_provider.dart';
import 'package:ama_legal_solutions/screen_helpers/accept_policy/accept_policy_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/app_complaint/delete_account_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/app_complaint/privacy_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/app_complaint/terms_and_conditions_helper.dart';

import 'package:ama_legal_solutions/screen_helpers/auth_helper/login_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/auth_helper/signup_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/delete_account/delete_account_request_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/advocate_casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/ama_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/home_screen_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/raise_query_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/services_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/onboarding_helper/get_started_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/onboarding_helper/splash_screen_helper.dart';
import 'package:ama_legal_solutions/screens/notifications/dark_notification_history_screen.dart';

import 'package:ama_legal_solutions/screens/notifications/dark_notification_screen.dart';

import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_screen_names.dart';

import 'package:ama_legal_solutions/screen_helpers/portfolio_helper/portfolio_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/profile_helper/profile_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppPathsForScreen.splashPath,
  routes: [
    GoRoute(
      path: AppPathsForScreen.splashPath,
      name: AppScreenNames.splash,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: SplashScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // Home
    GoRoute(
      path: AppPathsForScreen.userHomePath,
      name: AppScreenNames.userHome,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: const HomeScreenHelper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // Get Started
    GoRoute(
      path: AppPathsForScreen.getStartedPath,
      name: AppScreenNames.getStarted,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,

          child: GetStartedScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // SignUp
    GoRoute(
      path: AppPathsForScreen.signUpPath,
      name: AppScreenNames.signUp,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: ChangeNotifierProvider(
            create: (_) => SignupProvider(),
            child: SignupScreenHelper.getScreen(context),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // LogIn
    GoRoute(
      path: AppPathsForScreen.logInPath,
      name: AppScreenNames.logIn,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: ChangeNotifierProvider(
            create: (_) => LoginProvider(),
            child: LoginScreenHelper.getScreen(context),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    GoRoute(
      path: AppPathsForScreen.userAccountPath,
      name: AppScreenNames.userAccount,
      pageBuilder: (context, state) {
        String? name = state.uri.queryParameters["name"] ?? "";
        String? email = state.uri.queryParameters["email"] ?? "";
        String? profilePhoto = state.uri.queryParameters["profile_photo"] ?? "";
        String? role = state.uri.queryParameters["role"] ?? "";
        String? phone = state.uri.queryParameters["phone"] ?? "";

        final child = ProfileScreenHelper.getScreen(
          context,
          name,
          email,
          profilePhoto,
          phone,
          role,
        );

        // -------------------------------
        // ✅ iOS — Use CupertinoPage
        // This enables full swipe-back gesture automatically.
        // -------------------------------
        if (Platform.isIOS) {
          return CupertinoPage(key: state.pageKey, child: child);
        }

        // -------------------------------
        // ✅ Android — Keep your slide transition
        // -------------------------------
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: const Duration(milliseconds: 250),
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    ),
    // Portfolio
    GoRoute(
      path: AppPathsForScreen.portfolioPath,
      name: AppScreenNames.portfolio,
      pageBuilder: (context, state) {
        final userRole = state.uri.queryParameters["userRole"] ?? "N/A";

        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: PortfolioSreenHelper.getScreen(context, userRole),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // AMA
    GoRoute(
      path: AppPathsForScreen.amaPath,
      name: AppScreenNames.ama,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: Duration.zero,
          opaque: true,
          child: AmaScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // CaseDesk
    GoRoute(
      path: AppPathsForScreen.caseDeskPath,
      name: AppScreenNames.caseDesk,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: CaseDeskScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // Advocate CaseDesk
    GoRoute(
      path: AppPathsForScreen.advocateCaseDeskPath,
      name: AppScreenNames.advocateCaseDesk,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: AdvocateCasedeskScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // AMA Services
    GoRoute(
      path: AppPathsForScreen.amaServicesPath,
      name: AppScreenNames.amaServices,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: ServicesScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    // Raise Query
    GoRoute(
      path: AppPathsForScreen.raiseQueryPath,
      name: AppScreenNames.raiseQuery,
      pageBuilder: (context, state) {
        final String isQuestionPosting =
            state.uri.queryParameters["isQuestionPosting"] ?? "";
        final String isFilingDispute =
            state.uri.queryParameters["isFilingDispute"] ?? "";
        bool questionPosting = isQuestionPosting == "true" ? true : false;
        bool filingDispute = isFilingDispute == "true" ? true : false;
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: RaiseQueryScreenHelper.getScreen(
            context,
            questionPosting,
            filingDispute,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.notificationPath,
      name: AppScreenNames.notificationScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: const NotificationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.notificationHistoryPath,
      name: AppScreenNames.notificationHistoryScreen,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: Theme(
            data: Theme.of(context).copyWith(
              scaffoldBackgroundColor: Colors.black, // dark background
            ),
            child: const NotificationHistoryScreen(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.policyScreenPath,
      name: AppScreenNames.policyScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: PrivacyScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.termsAndConditionsPath,
      name: AppScreenNames.termsAndConditionsScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: TermsAndConditionsScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.deleteAccountPath,
      name: AppScreenNames.deleteAccountScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: DeleteAccountScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),

    GoRoute(
      path: AppPathsForScreen.acceptPolicyPath,
      name: AppScreenNames.acceptPolicyScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: AcceptPolicyScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.deleteAccountRequestPath,
      name: AppScreenNames.deleteAccountRequestScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: DeleteAccountRequestScreenHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
  ],
);
