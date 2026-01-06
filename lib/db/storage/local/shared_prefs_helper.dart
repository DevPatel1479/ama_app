import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<SharedPreferences> getPrefsInstance() async {
    return await SharedPreferences.getInstance();
  }
}
