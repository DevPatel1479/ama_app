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
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/admin_ama_leads_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/advocate_casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/ama_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/ama_leads_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/ask_laywer_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/bank_details_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/home_screen_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/live_case_status_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/meet_team_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/overview_casedesk_helper.dart';
import 'package:ama_legal_solutions/screen_helpers/main_content_helper/payment_view_helper.dart';
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

final loginProvider = LoginProvider();
final GoRouter appRouter = GoRouter(
  initialLocation: AppPathsForScreen.splashPath,
  refreshListenable: loginProvider,
  redirect: (context, state) {
    final isInitialized = loginProvider.isInitialized;
    final isLoggedIn = loginProvider.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == AppPathsForScreen.logInPath;

    if (!isInitialized) return null;

    if (!isLoggedIn) {
      return isGoingToLogin ? null : AppPathsForScreen.logInPath;
    }

    if (isLoggedIn && isGoingToLogin) {
      return AppPathsForScreen.userHomePath;
    }

    return null;
  },
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
          child: LoginScreenHelper.getScreen(context),

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
        final questionId = state.uri.queryParameters['questionId'];
        final commentId = state.uri.queryParameters['commentId'];
        return CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: Duration.zero,
          opaque: true,
          child: AmaScreenHelper.getScreen(
            context,
            tappedQuestionId: questionId,
            tappedCommentId: commentId,
          ),
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
    GoRoute(
      path: AppPathsForScreen.overviewCaseDeskPath,
      name: AppScreenNames.overviewCaseDeskScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: const OverviewCasedeskHelper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.paymentViewPath,
      name: AppScreenNames.paymentViewScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          child: const PaymentViewHelper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.liveCaseStatusPath,
      name: AppScreenNames.liveCaseStatusScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,

          // Push instantly
          transitionDuration: Duration.zero,

          // Pop with very fast smooth animation
          reverseTransitionDuration: const Duration(milliseconds: 150),

          child: const LiveCaseStatusHelper(),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0), // from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.bankDetailsPath,
      name: AppScreenNames.bankDetailsScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,

          // Push instantly
          transitionDuration: Duration.zero,

          // Pop with very fast smooth animation
          reverseTransitionDuration: const Duration(milliseconds: 150),

          child: const BankDetailsHelper(),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0), // from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
      },
    ),

    GoRoute(
      path: AppPathsForScreen.askLawyerPath,
      name: AppScreenNames.askLawyerScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,

          // Push instantly
          transitionDuration: Duration.zero,

          // Pop with very fast smooth animation
          reverseTransitionDuration: const Duration(milliseconds: 150),

          child: const AskLaywerHelper(),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0), // from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.meetTeamPath,
      name: AppScreenNames.meetTeamScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,

          // Push instantly
          transitionDuration: Duration.zero,

          // Pop with very fast smooth animation
          reverseTransitionDuration: const Duration(milliseconds: 150),

          child: const MeetTeamHelper(),

          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0), // from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.amaLeadsPath,
      name: AppScreenNames.amaLeadsScreen,
      pageBuilder: (context, state) {
        final name = state.uri.queryParameters["name"] ?? "";
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: AmaLeadsScreenHelper.getScreen(context, name),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
    GoRoute(
      path: AppPathsForScreen.adminAmaLeadsPath,
      name: AppScreenNames.adminAmaLeadsScreen,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: true,
          transitionDuration: Duration.zero,
          // child: ServicesScreenHelper.getScreen(context),
          child: AdminAmaLeadsHelper.getScreen(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // return FadeTransition(opacity: animation, child: child);
            return child;
          },
        );
      },
    ),
  ],
);
