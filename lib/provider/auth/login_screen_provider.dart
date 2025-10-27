import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool otpSent = false;
  String? role;
  String? name;
  String? email;
  String? weekTopic;
  bool weekTopicEnabled = false;

  bool _loginSuccess = false;
  bool get loginSuccess => _loginSuccess;

  // Controllers
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // Focus nodes for OTP boxes (required for backward/forward movement)
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  Future<void> login(BuildContext context) async {
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

        // Save name and role in local storage
        await LocalStorageHelper.saveString("userName", name!);
        await LocalStorageHelper.saveString("userRole", role!);
        await LocalStorageHelper.saveString("userEmail", email!);
        await LocalStorageHelper.saveString("userWeekTopic", weekTopic!);

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

  Future<void> verifyOtp(BuildContext context) async {
    final otp = otpControllers.map((c) => c.text).join();
    final phone = phoneController.text.trim();

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
        showCustomMessage(
          context,
          data["message"] ?? "OTP verified successfully",
          false,
        );
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
    _setLoading(false, successLogin: success);
  }

  void _setLoading(bool value, {bool successLogin = false}) {
    isLoading = value;
    _loginSuccess = successLogin;
    notifyListeners();
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
}
