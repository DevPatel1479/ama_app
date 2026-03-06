// firebase_options_ama.dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AmaCRMFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS || Platform.isMacOS) {
      return FirebaseOptions(
        apiKey: dotenv.env['AMACRM_IOS_API_KEY']!,
        appId: dotenv.env['AMACRM_IOS_APP_ID']!,
        messagingSenderId: dotenv.env['AMACRM_IOS_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['AMACRM_IOS_PROJECT_ID']!,
        storageBucket: dotenv.env['AMACRM_IOS_STORAGE_BUCKET']!,
        iosBundleId: dotenv.env['IOS_BUNDLE_ID']!,
      );
    } else {
      return FirebaseOptions(
        apiKey: dotenv.env['AMACRM_API_KEY']!,
        appId: dotenv.env['AMACRM_APP_ID']!,
        messagingSenderId: dotenv.env['AMACRM_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['AMACRM_PROJECT_ID']!,
        storageBucket: dotenv.env['AMACRM_STORAGE_BUCKET']!,
      );
    }
  }
}
