import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';

Future<String?> getUserName() {
  return LocalStorageHelper.getString("userName");
}

Future<String?> getUserRole() {
  return LocalStorageHelper.getString("userRole");
}

Future<String?> getUserEmail() {
  return LocalStorageHelper.getString("userEmail");
}

Future<String?> getUserPhone() {
  return LocalStorageHelper.getString("userPhone");
}

Future<bool?> getUserLoggedInStatus() {
  return LocalStorageHelper.getBool("isUserLoggedIn");
}
