import 'dart:async';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/firebase/fcm/firebase_messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RealTimeRoleProvider with ChangeNotifier {
  StreamSubscription<DocumentSnapshot>? _subscription;

  String? _role;
  String? get role => _role;

  /// Start real-time listener on user document (docId = phone number)
  void startRoleListener(String userPhone) async {
    print("listening to role changes for $userPhone");

    // Load previously saved role first
    _role = await LocalStorageHelper.getString("userRole");

    // Cancel previous listener if any
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('login_users')
        .doc(userPhone)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists) return;

          final data = snapshot.data() as Map<String, dynamic>?;
          final newRole = data?['role'];

          if (newRole == null) return;

          print("Firestore role: $newRole | Local role: $_role");

          // 🔥 Prevent unnecessary unsubscribe/subscribe on startup
          if (_role == newRole) {
            print("✔ Role unchanged. No topic switching.");
            return;
          }

          // --------------------------------------------------------
          // 1️⃣ Unsubscribe from OLD role topic
          // --------------------------------------------------------
          if (_role != null) {
            print("🔕 Unsubscribing from topic: $_role");
            await FirebaseMessagingService.instance.unsubscribeFromTopicFor();
          }

          // --------------------------------------------------------
          // 2️⃣ Save new role locally
          // --------------------------------------------------------
          _role = newRole;
          await LocalStorageHelper.saveString("userRole", newRole);

          // --------------------------------------------------------
          // 3️⃣ Subscribe to NEW role
          // --------------------------------------------------------
          print("🔔 Subscribing to topic: $newRole");
          await FirebaseMessagingService.instance.subscribeToTopicFor();

          notifyListeners();
        });
  }

  void setGuestRole() async {
    _subscription?.cancel(); // Stop any running listener safely
    _subscription = null;

    _role = "guest";
    await LocalStorageHelper.saveString("userRole", "guest");

    print("👤 Guest mode activated. No Firestore listener.");

    notifyListeners();
  }

  void setTesterRole() async {
    _subscription?.cancel(); // Stop any running listener safely
    _subscription = null;

    _role = "client";
    // await LocalStorageHelper.saveString("userRole", "client");

    print("👤 Client mode activated. No Firestore listener.");

    notifyListeners();
  }

  /// Stop listener (call on logout)
  void stop() {
    _subscription?.cancel();
    _role = null;
    print("Stopped role listener.");
    notifyListeners();
  }
}
