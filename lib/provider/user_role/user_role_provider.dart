import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _role;

  String? get role => _role;

  Future<void> loadUserRole() async {
    final storedRole = await LocalStorageHelper.getString('userRole');
    print("got role $storedRole");
    _role = storedRole?.toLowerCase();
    notifyListeners();
  }

  void setRole(String role) {
    _role = role.toLowerCase();
    notifyListeners();
  }

  void clearRole() {
    _role = null;
    notifyListeners();
  }
}
