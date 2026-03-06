import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:flutter/material.dart';

enum ApiStatus { idle, loading, success, error }

class ScheduledNotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ApiStatus _status = ApiStatus.idle;
  String? _errorMessage;
  String? _createdNotificationId;

  ApiStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get createdNotificationId => _createdNotificationId;

  /// Reset state (important for reuse)
  void reset() {
    _status = ApiStatus.idle;
    _errorMessage = null;
    _createdNotificationId = null;
    notifyListeners();
  }

  /// CREATE scheduled notification
  Future<bool> createScheduledNotification({
    required String userId,
    required List<String> topics,
    required String title,
    required String body,
    required String scheduledAtUtc,

    bool sendWeekly = false,
  }) async {
    _status = ApiStatus.loading;
    _errorMessage = null;
    _createdNotificationId = null;
    notifyListeners();

    try {
      final payload = {
        "user_id": userId,
        "topic": topics,
        "n_title": title,
        "n_body": body,
        "send_weekly": sendWeekly,
        "scheduled_at_utc": scheduledAtUtc,
      };

      final response = await _apiService.post(
        Endpoints.scheduleNotification,
        payload,
      );


      final decoded = jsonDecode(response.body);
      print("response ${decoded}");
      if (response.statusCode == 201 && decoded["success"] == true) {
        _status = ApiStatus.success;
        _createdNotificationId = decoded["id"];
        notifyListeners();
        return true;
      } else {
        _status = ApiStatus.error;
        _errorMessage = decoded["message"] ?? "Failed to schedule notification";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ApiStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
