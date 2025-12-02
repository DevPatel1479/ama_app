// lib/utils/global_notifiers.dart
import 'package:flutter/foundation.dart';

/// Private notifier (cannot be accessed outside this file)
final ValueNotifier<String?> _userNameNotifier = ValueNotifier(null);

final ValueNotifier<String?> _userEmailNotifier = ValueNotifier(null);

/// Public read-only interface
ValueListenable<String?> get globalUserName => _userNameNotifier;

ValueListenable<String?> get globalEmail => _userEmailNotifier;

/// Internal function to safely update the name
void updateGlobalUserName(String? newName) {
  print("updated user name");
  _userNameNotifier.value = newName;
}

void updateGlobalUserEmail(String? newEmail) {
  print("updated user email");
  _userEmailNotifier.value = newEmail;
}

/// Clear on logout (instantly reflects in UI)
void clearGlobals() {
  _userNameNotifier.value = null;
  _userEmailNotifier.value = null;
}
