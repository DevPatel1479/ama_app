import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background message received:');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  print('   Data: ${message.data}');

  // Handle background message processing
  // You can perform tasks like updating local storage, etc.
}

class FirebaseMessagingService {
  static FirebaseMessagingService? _instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessagingService._();

  static FirebaseMessagingService get instance {
    _instance ??= FirebaseMessagingService._();
    return _instance!;
  }

  /// Update FCM token when refreshed
  Future<void> updateFcmTokenOnServer(String newToken) async {
    try {
      print("🌍 Updating FCM token on server...");

      String? phone = await LocalStorageHelper.getString("userPhone");
      String? userRole = await LocalStorageHelper.getString("userRole");

      if (phone == null || userRole == null) {
        print(
          "⚠️ userPhone or userRole not found in storage. Cannot update token.",
        );
        return;
      }

      final apiService = ApiService();

      final response = await apiService.put(
        "${Endpoints.baseUrl}/fcm/update-fcm-token",
        {"user_id": phone, "fcm_token": newToken},
      );

      print("✅ Token update response: ${response.body}");

      // Save new token locally
      await LocalStorageHelper.saveString("fcmToken", newToken);
    } catch (e) {
      print("❌ Error updating refreshed token: $e");
    }
  }

  /// Initialize Firebase messaging and request permissions
  Future<void> initialize() async {
    try {
      print('🔥 Initializing Firebase Messaging...');

      // Initialize local notifications first
      await _initializeLocalNotifications();

      // Request notification permissions with system dialog
      bool permissionGranted = await _requestNotificationPermission();

      if (!permissionGranted) {
        print('⚠️ Notification permission denied by user');
        return;
      }
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      // await _subscribeToTopic();
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get the token
      // String? token = await _firebaseMessaging.getToken();
      // if (token != null) {
      //   print('✅ FCM Token obtained: ${token.substring(0, 20)}...');
      //   await _handleToken(token);
      // }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
        await updateFcmTokenOnServer(newToken);

        // _handleTokenRefresh(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }
    } catch (e) {
      print('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permission with system dialog
  Future<bool> _requestNotificationPermission() async {
    try {
      print('📱 Requesting notification permission...');

      // Request permission for iOS with system dialog
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      print(
        '📱 Notification permission status: ${settings.authorizationStatus}',
      );

      // Check if permission was granted
      bool isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (isGranted) {
        print('✅ Notification permission granted');
      } else {
        print('❌ Notification permission denied');
      }

      return isGranted;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationPermissionGranted() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('❌ Error checking notification permission: $e');
      return false;
    }
  }

  /// Manually request notification permission (can be called from UI)
  Future<bool> requestNotificationPermission() async {
    return await _requestNotificationPermission();
  }

  /// Get current notification permission status
  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      print('❌ Error getting notification permission status: $e');
      return AuthorizationStatus.denied;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('✅ Local notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  /// Handle foreground messages (when app is open)
  // void _handleForegroundMessage(RemoteMessage message) {
  //   print('📨 Foreground message received:');
  //   print('   Title: ${message.notification?.title}');
  //   print('   Body: ${message.notification?.body}');
  //   print('   Data: ${message.data}');

  //   // Show local notification
  //   _showLocalNotification(message);
  // }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message received:');
    print('   Title: ${message.data['title']}');
    print('   Body: ${message.data['body']}');
    print('   Data: ${message.data}');

    // Use data payload for accurate newlines
    _showLocalNotification(message);
  }

  /// Handle background messages (when app is in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    print('📨 Background message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Handle navigation or other actions based on message data
    _handleMessageAction(message);
  }

  /// Handle initial message (when app is terminated)
  void _handleInitialMessage(RemoteMessage message) {
    print('📨 Initial message received:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Handle navigation or other actions based on message data
    _handleMessageAction(message);
  }

  // /// Show local notification
  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   try {
  //     const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //         AndroidNotificationDetails(
  //           'ama_legal_solutions_channel',
  //           'AMA Legal Solutions',
  //           channelDescription: 'Notifications for AMA Legal Solutions app',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           showWhen: true,
  //         );

  //     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
  //         DarwinNotificationDetails(
  //           presentAlert: true,
  //           presentBadge: true,
  //           presentSound: true,
  //         );

  //     const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics,
  //     );

  //     await _localNotifications.show(
  //       message.hashCode,
  //       message.notification?.title ?? 'AMA Legal Solutions',
  //       message.notification?.body ?? 'New notification',
  //       platformChannelSpecifics,
  //       payload: message.data.toString(),
  //     );

  //     print('✅ Local notification displayed');
  //   } catch (e) {
  //     print('❌ Error showing local notification: $e');
  //   }
  // }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final title =
          message.data['title'] ??
          message.notification?.title ??
          'AMA Legal Solutions';
      final body =
          message.data['body'] ??
          message.notification?.body ??
          'New notification';

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'ama_legal_solutions_channel',
            'AMA Legal Solutions',
            channelDescription: 'Notifications for AMA Legal Solutions app',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            styleInformation: BigTextStyleInformation(
              '',
            ), // 👈 enables multiline
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      print('✅ Local notification displayed');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Notification tapped:');
    print('   Payload: ${response.payload}');

    // Parse payload and handle navigation
    if (response.payload != null) {
      // You can parse the payload and navigate to specific screens
      // For example: navigate to a specific question, profile, etc.
      print('📱 Handling notification tap action');
    }
  }

  /// Handle message action based on data
  void _handleMessageAction(RemoteMessage message) {
    final data = message.data;

    // Handle different types of notifications based on data
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'question_update':
          print('📋 Question update notification');
          // Navigate to questions screen or specific question
          break;
        case 'profile_update':
          print('👤 Profile update notification');
          // Navigate to profile screen
          break;
        case 'general':
          print('📢 General notification');
          // Show general message or navigate to home
          break;
        default:
          print('📨 Unknown notification type: ${data['type']}');
      }
    }

    // You can add more specific handling based on your app's needs
    // For example: navigate to specific screens, refresh data, etc.
  }

  Future<void> subscribeToTopicFor({
    bool weekEnabled = false,
    String weekEnabledValue = "",
  }) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // final userRole = prefs.getString('user_role');
      String? userRole = await LocalStorageHelper.getString("userRole");
      // String? userRole = "client";
      if (userRole == null) {
        print('⚠️ User role not found for topic subscription');
        return;
      }

      String topic;
      switch (userRole.toLowerCase()) {
        case 'client':
          topic = 'all_clients';
          break;
        case 'advocate':
          topic = 'all_advocates';
          break;
        case 'user':
          topic = 'all_users';
          break;
        case 'legal_expert':
          topic = 'all_legal_experts';
          break;

        default:
          print('⚠️ Unknown user role for topic subscription: $userRole');
          return;
      }
      if (weekEnabled) {
        await _firebaseMessaging.subscribeToTopic(weekEnabledValue);
        print('✅ Subscribed to topic: $weekEnabledValue');
      }
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic for role: $userRole');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic based on user role
  Future<void> unsubscribeFromTopicFor({String? weekTopicValue}) async {
    try {
      String? userRole = await LocalStorageHelper.getString("userRole");

      if (userRole == null) {
        print('⚠️ User role not found for topic unsubscription');
        return;
      }

      String topic;
      switch (userRole.toLowerCase()) {
        case 'client':
          topic = 'all_clients';
          break;
        case 'advocate':
          topic = 'all_advocates';
          break;
        case 'user':
          topic = 'all_users';
          break;
        case 'legal_expert':
          topic = 'all_legal_experts';
          break;
        default:
          print('⚠️ Unknown user role for topic unsubscription: $userRole');
          return;
      }
      if (weekTopicValue != null) {
        await _firebaseMessaging.unsubscribeFromTopic(weekTopicValue);
        print('✅ Unsubscribed from topic: $weekTopicValue');
      }
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic for role: $userRole');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  // /// Manually subscribe to topic (can be called from UI)
  // Future<bool> subscribeToTopic(String topic) async {
  //   try {
  //     await _firebaseMessaging.subscribeToTopic(topic);
  //     print('✅ Manually subscribed to topic: $topic');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error manually subscribing to topic: $e');
  //     return false;
  //   }
  // }

  /// Manually unsubscribe from topic (can be called from UI)
  // Future<bool> unsubscribeFromTopic(String topic) async {
  //   try {
  //     await _firebaseMessaging.unsubscribeFromTopic(topic);
  //     print('✅ Manually unsubscribed from topic: $topic');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error manually unsubscribing from topic: $e');
  //     return false;
  //   }
  // }

  Future<String?> generateFcmToken() async {
    try {
      print('🔥 Generating new FCM token...');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();

      if (token == null) {
        print('❌ Failed to generate FCM token.');
        return null;
      }

      print('✅ FCM Token generated: ${token.substring(0, 20)}...');

      // Save locally for app use
      // await LocalStorageHelper.setString("fcmToken", token);

      return token;
    } catch (e) {
      print('❌ Error generating FCM token: $e');
      return null;
    }
  }
}
