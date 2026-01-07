import 'dart:convert';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart'
    show LocalStorageHelper;
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/models/notifcation_history_model.dart';

class NotificationHistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// ===== 🔹 State Management =====
  bool isLoading = false; // for initial loading
  bool isPaginating = false; // for "load more"
  bool hasMore = true; // whether more pages exist
  bool _adminHasFetchedLastSeen = false;
  List<NotificationHistoryModel> notifications = [];
  int? _adminLastOpenedNotificationTime;

  int? get adminLastOpenedNotificationTime => _adminLastOpenedNotificationTime;

  /// Cursor-based pagination
  String? _lastTimestamp;

  /// Reset before fresh fetch
  void reset({bool keepLastOpened = true}) {
    notifications.clear();
    hasMore = true;
    _lastTimestamp = null;
    _adminHasFetchedLastSeen = false;
    isLoading = true;
    if (!keepLastOpened) {
      _adminLastOpenedNotificationTime = null;
    }

    notifyListeners();
  }

  Future<void> adminFetchLastOpenedNotificationTime({
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.adminLastSeenNotification,
        {"phone": phone},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final lastOpened = data['adminLastOpenedNotificationTime'];
          _adminLastOpenedNotificationTime = lastOpened is int
              ? lastOpened
              : int.tryParse(lastOpened.toString());
          print(
            'adminLastOpenedNotificationTime: $_adminLastOpenedNotificationTime',
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch last opened time: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminUpdateLastOpenedNotificationTime({
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(Endpoints.adminMarkNotification, {
        "phone": phone,
      });
      print(response.body);

      // Locally update to avoid refetch
      _adminLastOpenedNotificationTime =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      debugPrint("Failed to update last opened time: $e");
    }
  }

  /// ===== 🔹 Fetch User Notification History =====
  Future<void> fetchUserNotificationHistory(
    String userId, {
    bool loadMore = false,
  }) async {
    if (isLoading || (loadMore && !hasMore)) return;
    final phone = await LocalStorageHelper.getString("userPhone");

    if (loadMore) {
      isPaginating = true;
    } else {
      isLoading = true;
      reset(keepLastOpened: true);
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
