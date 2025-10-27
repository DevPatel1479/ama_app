import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Send notification to specific topic or role
  Future<void> sendNotification({
    required BuildContext context,
    required String userId,
    required String topic,
    required String title,
    required String body,
    List<String>? topics,
    bool send_weekly = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService
          .post(Endpoints.sendTopicNotifications, {
            "user_id": userId,
            "topic": (topic.isEmpty || topic == "") ? topics : topic,
            "n_title": title,
            "n_body": body,
            if (send_weekly) "send_weekly": true,
          });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        showCustomMessage(
          context,
          data['message'] ?? "Notification sent!",
          false,
        );
      } else {
        showCustomMessage(
          context,
          data['message'] ?? "Failed to send notification",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, "Error: ${e.toString()}", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Fetch notifications with proper pagination and duplicate prevention
  Future<void> fetchNotifications({
    required BuildContext context,
    required String role,
    bool loadMore = false,
  }) async {
    if (loadMore && !_hasMore) return;

    if (!loadMore) {
      _currentPage = 1;
      _notifications.clear();
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        "${Endpoints.getNotifications(role)}?page=$_currentPage&limit=$_limit",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final newNotifications = NotificationModel.fromJsonList(
            response.body,
          );

          // ✅ Remove duplicates based on notification ID
          final existingIds = _notifications.map((n) => n.id).toSet();
          final uniqueNew = newNotifications
              .where((n) => !existingIds.contains(n.id))
              .toList();

          // ✅ Check if more pages available
          if (uniqueNew.length < _limit) _hasMore = false;

          _notifications.addAll(uniqueNew);
          _currentPage++;

          notifyListeners();
        } else {
          showCustomMessage(
            context,
            data['message'] ?? "No notifications found",
            true,
          );
          _hasMore = false;
        }
      } else {
        showCustomMessage(
          context,
          "Failed with code ${response.statusCode}",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, "Error: ${e.toString()}", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _hasMore = true;
    _currentPage = 1;
    notifyListeners();
  }
}
