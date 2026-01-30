import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/material.dart' show ChangeNotifier;

class NotificationReadStateProvider extends ChangeNotifier {
  static const _key = "has_new_notification";

  bool _hasNewNotification = false;

  bool get hasNewNotification => _hasNewNotification;

  /// Called when app starts
  Future<void> loadNotificationStatus() async {
    _hasNewNotification = await LocalStorageHelper.getBool(_key) ?? false;
    print("checking the notification state ${_hasNewNotification}");
    notifyListeners();
  }

  /// When notification arrives
  Future<void> setNewNotification(bool value) async {
    _hasNewNotification = value;
    await LocalStorageHelper.saveBool(_key, value);
    notifyListeners();
  }

  /// When user opens notification screen
  Future<void> clearNotification() async {
    _hasNewNotification = false;
    await LocalStorageHelper.saveBool(_key, false);
    notifyListeners();
  }
}
