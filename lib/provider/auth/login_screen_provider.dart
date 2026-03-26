import 'dart:async' show Timer;
import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/firebase/fcm/firebase_messaging_service.dart';
import 'package:ama_legal_solutions/login_status_sync/login_status_sync.dart';
import 'package:ama_legal_solutions/provider/theme/theme_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/real_time_role_provider.dart';
import 'package:ama_legal_solutions/provider/user_role/user_role_provider.dart';
import 'package:ama_legal_solutions/routes/app_paths_screen.dart';
import 'package:ama_legal_solutions/routes/app_router.dart';
import 'package:ama_legal_solutions/screens/roles/user/data_fetch_methods/user_data_fetch.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool isLoading = false;
  bool otpSent = false;
  String? role;
  String? name;
  String? email;
  String? weekTopic;
  bool weekTopicEnabled = false;

  String countryCode = "+91";

  String get getSelectedCountryCode => countryCode;

  bool _loginSuccess = false;
  bool get loginSuccess => _loginSuccess;

  // Controllers
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  int _secondsRemaining = 30;
  bool get isResendAvailable => _secondsRemaining == 0;
  int get secondsRemaining => _secondsRemaining;
  Timer? _resendTimer;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  static const _keySessionExpiry = "session_expiry";
  // Focus nodes for OTP boxes (required for backward/forward movement)
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  String normalizeCountryCode(String code) {
    return code.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> initialize(BuildContext context) async {
    final loggedIn =
        await LocalStorageHelper.getBool("isUserLoggedIn") ?? false;

    final expiryString = await LocalStorageHelper.getString(_keySessionExpiry);

    print("expiry time .. $expiryString");

    if (!loggedIn) {
      _isLoggedIn = false;
      _isInitialized = true; // ✅ ADD THIS
      notifyListeners();
      return;
    }

    if (expiryString == null) {
      await createSession();
      _isLoggedIn = true;
      _isInitialized = true; // ✅ ADD THIS
      notifyListeners();
      return;
    }

    final expiryTime = DateTime.parse(expiryString);

    if (DateTime.now().isAfter(expiryTime)) {
      if (!context.mounted) return;
      print("triggering logout ... init state");
      await logout(context);
      _isLoggedIn = false;
    } else {
      _isLoggedIn = true;
    }

    _isInitialized = true; // ✅ KEEP THIS
    notifyListeners();
  }

  Future<void> checkSession(BuildContext context) async {
    final expiryString = await LocalStorageHelper.getString(_keySessionExpiry);

    if (expiryString == null) return;

    final expiryTime = DateTime.parse(expiryString);

    if (DateTime.now().isAfter(expiryTime)) {
      if (!context.mounted) return;
      print("triggering logout ... in checksession ");

      await logout(context);
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> logout(
    BuildContext context, {
    GoRouter? router,
    String? role,
  }) async {
    // 1️⃣ Immediately update state so redirect works
    _isLoggedIn = false;
    notifyListeners();

    // 2️⃣ Navigate to login screen immediately
    if (appRouter != null) {
      appRouter.go(AppPathsForScreen.logInPath);
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final roleProvider = Provider.of<RealTimeRoleProvider>(
      context,
      listen: false,
    );

    try {
      final phone = await getUserPhone();

      // 🔥 Backend sync
      await LoginStatusSyncService.updateLoginStatus(
        phone: phone ?? "",
        logout: true,
      );

      final wasDark = themeProvider.isDarkMode;

      // Stop realtime listeners
      roleProvider.stop();

      // Unsubscribe topics
      final weekTopic = await LocalStorageHelper.getString("userWeekTopic");
      await FirebaseMessagingService.instance.unsubscribeFromTopicFor(
        weekTopicValue: weekTopic,
      );

      // Clear everything
      await LocalStorageHelper.clearAll();

      // Restore important flags
      await themeProvider.setTheme(wasDark);
      await LocalStorageHelper.saveBool("isAcceptedPolicy", true);
      await LocalStorageHelper.saveBool("isDeleteRequestMade", true);
      await LocalStorageHelper.saveBool("isGetStartedTapped", true);

      if (role == "guest") {
        await LocalStorageHelper.saveBool("isGuestLoggedOut", true);
      } else {
        await LocalStorageHelper.saveBool("isNormalUser", true);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSession() async {
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month + 2, now.day);
    await LocalStorageHelper.saveString(
      _keySessionExpiry,
      // DateTime.now()
      //     .add(const Duration(days: 7)) // 1 week session
      //     .toIso8601String(),
      expiry.toIso8601String(),
    );
  }

  void setCountryCode(String code) {
    countryCode = code;
    notifyListeners();
  }

  // Start the countdown timer
  void startResendTimer() {
    _secondsRemaining = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _resendTimer?.cancel();
        notifyListeners();
      }
    });
  }

  // Stop timer when no longer needed
  void stopResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _secondsRemaining = 0;
    notifyListeners();
  }

  // Resend OTP logic
  Future<void> resendOtp(BuildContext context) async {
    if (!isResendAvailable) return;
    final phone = phoneController.text.trim();
    await sendOtp(context, phone);
    startResendTimer();
  }

  Future<void> login(BuildContext context) async {
    // final countryC = normalizeCountryCode(countryCode);

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      showCustomMessage(context, "Phone number cannot be empty", true);
      return;
    }

    _setLoading(true);
    try {
      final response = await _apiService.post(Endpoints.login, {
        "phone": phone,
      });
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        name = data["name"];
        role = data["role"];
        email = data["email"];
        weekTopic = data["week_topic"];
        weekTopicEnabled = true;

        updateGlobalUserName(name!);
        updateGlobalUserEmail(email!);
        // Save name and role in local storage
        await LocalStorageHelper.saveString("userName", name!);
        await LocalStorageHelper.saveString("userRole", role!);
        await LocalStorageHelper.saveString("userEmail", email!);
        await LocalStorageHelper.saveString("userWeekTopic", weekTopic!);

        final userProvider = context.read<UserProvider>();
        await userProvider.loadUserRole();

        // _showFlushbar(context, "Login successful", Colors.green);
        // showCustomMessage(context, "Login successful", true);
        // Now send OTP
        await sendOtp(context, phone);
      } else {
        // _showFlushbar(context, data["message"] ?? "Login failed", Colors.red);
        showCustomMessage(context, data["error"] ?? "Login failed", true);
      }
    } catch (e) {
      // _showFlushbar(context, e.toString(), Colors.red);
      showCustomMessage(context, e.toString(), true);
    }
    _setLoading(false);
  }

  Future<void> sendOtp(BuildContext context, String phone) async {
    if (role == null) {
      showCustomMessage(
        context,
        "Role not available. Please login again.",
        true,
      );
      return;
    }

    try {
      final response = await _apiService.post(Endpoints.sendOtp, {
        "phone": phone,
        "role": role,
      });
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        otpSent = true;
        startResendTimer();
        notifyListeners();
        showCustomMessage(
          context,
          data["message"] ?? "OTP sent successfully",
          false,
        );
      } else {
        showCustomMessage(
          context,
          data["message"] ?? "Failed to send OTP",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, e.toString(), true);
    }
  }

  /// Generate and store FCM token to backend
  Future<void> generateAndStoreFcmToken(String userId) async {
    try {
      print("🔥 Fetching FCM token...");

      String? token = await FirebaseMessagingService.instance
          .generateFcmToken();

      if (token == null) {
        print("❌ Failed to generate FCM token");
        return;
      }

      // print("✅ FCM Token: $token");

      // Save token locally
      // await LocalStorageHelper.saveString("fcmToken", token);

      // ---- API CALL ----
      final apiService = ApiService();
      final response = await apiService.post(
        "${Endpoints.baseUrl}/fcm/store-fcm-token",
        {
          "user_id": userId, // phone you stored
          "fcm_token": token,
        },
      );

      print("🌍 Store Token Response: ${response.body}");
    } catch (e) {
      print("❌ Error generating or storing FCM token: $e");
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (isLoading) return;

    final otp = otpControllers.map((c) => c.text).join();
    // final cCode = normalizeCountryCode(countryCode);

    final phone = phoneController.text.trim();

    // print(phone);

    if (otp.length != 6) {
      showCustomMessage(context, "Enter complete OTP", true);
      return;
    }

    _setLoading(true);
    bool success = false;
    try {
      final response = await _apiService.post(Endpoints.verifyOtp, {
        "phone": phone,
        "role": role,
        "otp": otp,
      });
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        await LocalStorageHelper.saveBool("isUserLoggedIn", true);

        await LocalStorageHelper.saveString("userPhone", phone);
        await createSession();

        final userId = "${role}_${phone}";
        generateAndStoreFcmToken(userId);
        await LoginStatusSyncService.updateLoginStatus(
          phone: phone,
          logout: false,
        );
        await LocalStorageHelper.saveBool("isLogInStatusInserted", true);
        // showCustomMessage(
        //   context,
        //   data["message"] ?? "OTP verified successfully",
        //   false,
        // );
        _isLoggedIn = true;
        success = true;
        // _setLoading(false, successLogin: true);
      } else {
        showCustomMessage(
          context,
          data["message"] ?? "OTP verification failed",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, e.toString(), true);
    }
    await _setLoading(success, successLogin: success);
  }

  Future<void> _setLoading(bool value, {bool successLogin = false}) async {
    // if (!hasListeners) return;
    isLoading = value;
    _loginSuccess = successLogin;
    if (successLogin) {
      if (weekTopicEnabled) {
        await FirebaseMessagingService.instance.subscribeToTopicFor(
          weekEnabled: weekTopicEnabled,
          weekEnabledValue: weekTopic ?? "",
        );
      } else {
        await FirebaseMessagingService.instance.subscribeToTopicFor();
      }
    }

    if (hasListeners) notifyListeners();
  }

  //   void _showFlushbar(BuildContext context, String message, Color color) {
  //     final snackBar = SnackBar(
  //       content: Text(message, style: const TextStyle(color: Colors.white)),
  //       backgroundColor: color,
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 2),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  void resetLoginState() {
    phoneController.clear();

    for (var c in otpControllers) {
      c.clear();
    }

    otpSent = false;
    isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}
