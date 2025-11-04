import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ Initialize Firebase
    FirebaseApp.configure()

    // ✅ Set UNUserNotificationCenter delegate
    UNUserNotificationCenter.current().delegate = self

    // ✅ Register for remote notifications (required for APNs)
    application.registerForRemoteNotifications()

    // ✅ Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ This method passes APNs token to Firebase Messaging
  override func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("✅ APNs token registered with Firebase Messaging")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}