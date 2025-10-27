import 'package:ama_legal_solutions/db/storage/local/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageHelper {
  static Future<SharedPreferences> get _instance async {
    return await SharedPreferencesHelper.getPrefsInstance();
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  static Future<void> clear(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
