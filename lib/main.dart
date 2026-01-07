import 'dart:io' show Platform;

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/firebase/fcm/firebase_messaging_service.dart';
import 'package:ama_legal_solutions/firebase/firebase_options.dart';
import 'package:ama_legal_solutions/provider/ama/answer_provider.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/client/remarks_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/notification_history_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/notification_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/weekly_client_count_provider.dart';
import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/resolve_query_provider.dart';
import 'package:ama_legal_solutions/provider/teams/team_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_router.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Make app truly immersive (behind home indicator)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await dotenv.load(fileName: ".env");

  if (Platform.isIOS) {
    debugPrint("iOS: Audio mix policy handled automatically by video_player.");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessagingService.instance.initialize();
    // print("Firebase connected successfully !!");
  } catch (e) {
    // print("Error connecting firebase $e");
  }
  final themeProvider = await ThemeProvider.create();
  final userProvider = UserProvider();
  await userProvider.loadUserRole();
  // debugProfileBuildsEnabled = true;
  // debugProfilePaintsEnabled = true;
  // runApp(const MyApp());
  final savedName = await LocalStorageHelper.getString("userName");
  final savedEmail = await LocalStorageHelper.getString("userEmail");
  updateGlobalUserName(savedName);
  updateGlobalUserEmail(savedEmail);
  // ✅ CHECK IF USER IS LOGGED IN
  final isLoggedIn =
      await LocalStorageHelper.getBool("isUserLoggedIn") ?? false;
  final savedPhone = await LocalStorageHelper.getString("userPhone");
  final initialRole = await LocalStorageHelper.getString("userRole") ?? "N/A";
  // 👇 We create providers ONCE so we can access RealTimeRoleProvider
  final realTimeRoleProvider = RealTimeRoleProvider();
  if (initialRole == "guest") {
    realTimeRoleProvider.setGuestRole();
  }
  // ✅ If user already logged in → Start real-time role listener immediately
  else if (isLoggedIn && savedPhone != null && savedPhone.isNotEmpty) {
    realTimeRoleProvider.startRoleListener("91${savedPhone}");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<RealTimeRoleProvider>.value(
          value: realTimeRoleProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => TeamProvider(apiService: ApiService()),
        ), // added profile provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ), // added profile provider
        ChangeNotifierProvider(
          create: (_) => UserInfoProvider(),
        ), // added profile provider
        ChangeNotifierProvider(create: (_) => QueryProvider()),
        ChangeNotifierProvider(
          create: (_) => QuestionProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(create: (_) => RemarksProvider()),
        ChangeNotifierProvider(create: (_) => ResolveQueryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnswerProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyClientCountProvider()),
        ChangeNotifierProvider(create: (_) => NotificationHistoryProvider()),
      ],
      child: const AmaLegalSolutionsApp(),
    ),
  );
}

class AmaLegalSolutionsApp extends StatelessWidget {
  const AmaLegalSolutionsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AMA Legal Solutions',
      routerConfig: appRouter,
      // routerDelegate: appRouter.routerDelegate,
    );
  }
}
