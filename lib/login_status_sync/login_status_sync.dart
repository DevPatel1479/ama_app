import 'dart:async';

import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginStatusSyncService {
  static bool _initialized = false;

  static void syncLoginStatusIfNeeded(String phone) {
    if (_initialized) return;
    _initialized = true;

    // Run async but DO NOT await
    Future.microtask(() async {
      final isLoggedIn =
          await LocalStorageHelper.getBool("isUserLoggedIn") ?? false;
      if (!isLoggedIn) {
        print("returning user is not logged in  .. ");
        // user is not logged in → nothing to do
        return;
      }

      // 2️⃣ Now check if already inserted
      final isInserted =
          await LocalStorageHelper.getBool("isLogInStatusInserted") ?? false;

      if (isInserted) {
        // already synced once → nothing to do
        return;
      }
      print("isinserted... $isInserted");
      // 3️⃣ Insert login status
      updateLoginStatus(phone: phone, logout: false);

      // 4️⃣ Mark as inserted so this never runs again
      await LocalStorageHelper.saveBool("isLogInStatusInserted", true);
    });
  }

  static Future<void> updateLoginStatus({
    required String phone,
    required bool logout,
  }) async {
    print("checking login status ... ");
    try {
      final uri = Uri.parse("${Endpoints.baseUrl}/login-status");

      http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "logout": logout}),
      );

      // 🔥 no await → fire & forget
    } catch (_) {
      // intentionally ignored (no UX impact)
    }
  }
}
