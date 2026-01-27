import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/firebase/fcm/firebase_messaging_service.dart';

class FcmSyncTokenManager {
  static final FcmSyncTokenManager _instance = FcmSyncTokenManager._internal();

  factory FcmSyncTokenManager() => _instance;

  FcmSyncTokenManager._internal();

  /// Fire-and-forget startup sync
  void start() {
    _syncInitialToken();
  }

  /// ---------------------------
  /// INITIAL TOKEN SYNC
  /// ---------------------------
  Future<void> _syncInitialToken() async {
    try {
      final isLoggedIn =
          await LocalStorageHelper.getBool("isUserLoggedIn") ?? false;
      if (!isLoggedIn) return;
      final role = await LocalStorageHelper.getString("userRole") ?? "guest";
      if (role == "guest") return; // Skip guest

      final storedToken = await LocalStorageHelper.getString("fcmToken");
      final currentToken = await FirebaseMessagingService.instance
          .getCurrentFcmToken();

      if (currentToken == null) {
        print("⚠️ Current FCM token is null");
        return;
      }

      if (storedToken == currentToken) {
        print("✅ FCM token unchanged, no API call needed");
        return;
      }

      await _sendTokenToBackend(currentToken, role);
      await LocalStorageHelper.saveString("fcmToken", currentToken);
    } catch (e) {
      print("❌ Error during initial FCM sync: $e");
    }
  }

  /// ---------------------------
  /// FIRE-AND-FORGET API CALL
  /// ---------------------------
  Future<void> _sendTokenToBackend(String token, String role) async {
    final phone = await LocalStorageHelper.getString("userPhone") ?? "";
    if (phone.isEmpty) return;

    final userId = "${role}_$phone";
    final apiService = ApiService();

    // Fire-and-forget, errors logged inside
    Future.microtask(() async {
      try {
        await apiService.post("${Endpoints.baseUrl}/fcm/store-fcm-token", {
          "user_id": userId,
          "fcm_token": token,
        });
        print("✅ FCM token sent to backend successfully");
      } catch (e) {
        print("❌ Failed to send FCM token to backend: $e");
      }
    });
  }
}
