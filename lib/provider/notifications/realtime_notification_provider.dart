import 'dart:async';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RealtimeNotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  bool _hasUnread = false;
  bool get hasUnread => _hasUnread;

  bool _listenerStarted = false;
  String? _role;

  /// Restore unread flag from local storage
  Future<void> restoreUnreadState() async {
    _hasUnread =
        await LocalStorageHelper.getBool("has_unread_notification") ?? false;
  }

  void onRoleChanged(String? role) {
    role = role?.toLowerCase();

    if (role == null || role == "guest") {
      stopListening();
      clearUnread();
      return;
    }

    startListening(role);
  }

  /// Start listening to Firestore for new notifications
  void startListening(String role) {
    if (role == "guest" || role == "admin") return;

    // Only restart if role changed or not yet listening
    if (_role == role && _subscription != null) return;

    stopListening(); // cancel previous listener if any
    _role = role;
    _listenerStarted = false;
    print("started listening to this role $_role");
    final path = _firestore
        .collection("notifications")
        .doc(role)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1);

    _subscription = path.snapshots().listen(
      (snapshot) async {
        // Skip the first snapshot on startup to avoid "always red dot"
        if (!_listenerStarted) {
          _listenerStarted = true;
          return;
        }

        // Only mark unread if a new document is added
        final addedDocs = snapshot.docChanges.where(
          (change) => change.type == DocumentChangeType.added,
        );

        if (addedDocs.isNotEmpty) {
          _hasUnread = true;
          notifyListeners();
          await LocalStorageHelper.saveBool("has_unread_notification", true);
        }
      },
      onError: (e) {
        debugPrint("Firestore listener error: $e");
      },
    );
  }

  /// Clear unread flag
  void clearUnread() async {
    _hasUnread = false;
    notifyListeners();
    await LocalStorageHelper.saveBool("has_unread_notification", false);
  }

  /// Stop listening
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _role = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
