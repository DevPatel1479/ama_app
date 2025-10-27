import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/firebase/fcm/firebase_messaging_service.dart';
import 'package:ama_legal_solutions/firebase/firebase_options.dart';
import 'package:ama_legal_solutions/provider/ama/answer_provider.dart';
import 'package:ama_legal_solutions/provider/ama/comment_provider.dart';
import 'package:ama_legal_solutions/provider/ama/question_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/notification_provider.dart';
import 'package:ama_legal_solutions/provider/notifications/weekly_client_count_provider.dart';
import 'package:ama_legal_solutions/provider/profile/profile_photo_provider.dart';
import 'package:ama_legal_solutions/provider/profile/user_info_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/query_provider.dart';
import 'package:ama_legal_solutions/provider/raise_query/resolve_query_provider.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessagingService.instance.initialize();
    print("Firebase connected successfully !!");
  } catch (e) {
    print("Error connecting firebase $e");
  }
  final themeProvider = await ThemeProvider.create();
  // runApp(const MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
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
        ChangeNotifierProvider(create: (_) => ResolveQueryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnswerProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyClientCountProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
