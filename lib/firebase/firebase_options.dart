import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS || Platform.isMacOS) {
      // ---- iOS Configuration ----
      return FirebaseOptions(
        apiKey: dotenv.env['IOS_API_KEY']!,
        appId: dotenv.env['IOS_APP_ID']!,
        messagingSenderId: dotenv.env['IOS_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['IOS_PROJECT_ID']!,
        storageBucket: dotenv.env['IOS_STORAGE_BUCKET']!,
        iosBundleId: dotenv.env['IOS_BUNDLE_ID']!,
      );
    } else {
      // ---- Android Configuration ----
      return FirebaseOptions(
        apiKey: dotenv.env['API_KEY']!,
        appId: dotenv.env['APP_ID']!,
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['PROJECT_ID']!,
        storageBucket: dotenv.env['STORAGE_BUCKET']!,
      );
    }
  }
}
