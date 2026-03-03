// firebase/ama_crm_firebase.dart
import 'package:ama_legal_solutions/firebase/firebase_options_ama_crm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AmaCrmFirebase {
  static const _appName = "amaCrm";
  static FirebaseApp? _app;
  static FirebaseFirestore? _firestore;

  static Future<FirebaseFirestore> getFirestore() async {
    // 🔒 Already initialized? reuse it
    if (_firestore != null) return _firestore!;

    // 🔍 Check if app already exists (hot restart / navigation)
    try {
      _app = Firebase.app(_appName);
    } catch (_) {
      _app = await Firebase.initializeApp(
        name: _appName,
        options: AmaCRMFirebaseOptions.currentPlatform,
      );
    }

    _firestore = FirebaseFirestore.instanceFor(app: _app!);
    return _firestore!;
  }

  static bool get isInitialized => _firestore != null;
}
