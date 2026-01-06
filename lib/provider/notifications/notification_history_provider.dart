import 'dart:convert';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/models/notifcation_history_model.dart';

class NotificationHistoryProvider extends ChangeNotifier {
  /// ===== 🔹 State Management =====
  bool isLoading = false; // for initial loading
  bool isPaginating = false; // for "load more"
  bool hasMore = true; // whether more pages exist

  List<NotificationHistoryModel> notifications = [];

  /// Cursor-based pagination
  String? _lastTimestamp;

  /// Reset before fresh fetch
  void reset() {
    notifications.clear();
    hasMore = true;
    _lastTimestamp = null;
    notifyListeners();
  }

  /// ===== 🔹 Fetch User Notification History =====
  Future<void> fetchUserNotificationHistory(
    String userId, {
    bool loadMore = false,
  }) async {
    if (isLoading || (loadMore && !hasMore)) return;

    if (loadMore) {
      isPaginating = true;
    } else {
      isLoading = true;
      reset();
    }
    notifyListeners();

    try {
      const int pageSize = 10;
      final apiService = ApiService();

      final queryParams = {
        'pageSize': pageSize.toString(),
        if (_lastTimestamp != null) 'lastTimestamp': _lastTimestamp!,
      };

      final url = Uri.parse(
        '${Endpoints.getNotificationHistory(userId)}?${Uri(queryParameters: queryParams).query}',
      );

      final response = await apiService.get(url.toString());
      final Map<String, dynamic> body = json.decode(response.body);

      if (body['success'] == true) {
        final List<dynamic> data = body['data'] ?? [];
        final List<NotificationHistoryModel> fetched = data
            .map((e) => NotificationHistoryModel.fromJson(e))
            .toList();

        if (!loadMore) {
          notifications = fetched;
        } else {
          // ✅ avoid duplicates
          final existingIds = notifications.map((n) => n.id).toSet();
          final newItems = fetched
              .where((n) => !existingIds.contains(n.id))
              .toList();
          notifications.addAll(newItems);
        }

        hasMore = fetched.length == pageSize;
        _lastTimestamp = body['nextCursor']?.toString();
      } else {
        hasMore = false;
      }
    } catch (e, st) {
      debugPrint("❌ Error fetching user notification history: $e");
      debugPrintStack(stackTrace: st);
      hasMore = false;
    } finally {
      isLoading = false;
      isPaginating = false;
      notifyListeners();
    }
  }
}
