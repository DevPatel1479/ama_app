import 'package:ama_legal_solutions/routes/app_paths_screen.dart'
    show AppPathsForScreen;
import 'package:ama_legal_solutions/routes/app_router.dart';
import 'package:flutter/material.dart' show WidgetsBinding;

bool get isRouterReady {
  final ctx = appRouter.routerDelegate.navigatorKey.currentContext;
  return ctx != null && ctx.mounted;
}

String? pendingDeepLink;

class NotificationNavigation {
  static void handle(Map<String, dynamic> data) {
    final type = data['type'];
    final questionId = data['questionId'];
    final commentId = data['commentId'];

    String? uri;

    /// ✅ AMA ANSWER → highlight QUESTION
    if (type == 'ama_answer' && questionId != null) {
      uri = Uri(
        path: AppPathsForScreen.amaPath,
        queryParameters: {'questionId': questionId},
      ).toString();
    }

    /// ✅ AMA COMMENT → open COMMENTS + highlight COMMENT
    if (type == 'ama_comment' && questionId != null && commentId != null) {
      uri = Uri(
        path: AppPathsForScreen.amaPath,
        queryParameters: {'questionId': questionId, 'commentId': commentId},
      ).toString();
    }

    if (uri == null) {
      print("⚠️ Unknown notification type: $type");
      return;
    }

    print("🔗 Deep link: $uri");

    if (!isRouterReady) {
      pendingDeepLink = uri;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go(uri!);
      });
    }
  }
}
