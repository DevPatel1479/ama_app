import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  // Fields
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  String selectedState = '';
  String queries = '';
  String sourceReference = '';
  String otherSource = ''; // For "Other" input

  // Error messages
  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? stateError;
  String? sourceError;

  // Setters
  void setFullName(String value) {
    fullName = value;
    fullNameError = null;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    emailError = null;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    phoneNumber = value;
    phoneError = null;
    notifyListeners();
  }

  void setState(String value) {
    selectedState = value;
    stateError = null;
    notifyListeners();
  }

  void setQueries(String value) {
    queries = value;
    notifyListeners();
  }

  void setSourceReference(String value) {
    sourceReference = value;
    sourceError = null;
    notifyListeners();
  }

  void setOtherSource(String value) {
    otherSource = value;
    sourceError = null;
    notifyListeners();
  }

  // Validate the form
  bool validateForm() {
    bool isValid = true;

    // Clear previous errors
    fullNameError = null;
    emailError = null;
    phoneError = null;
    stateError = null;
    sourceError = null;

    if (fullName.isEmpty) {
      fullNameError = "Full Name is required";
      isValid = false;
    }

    if (email.isEmpty) {
      emailError = "Email is required";
      isValid = false;
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email)) {
      emailError = "Invalid email format";
      isValid = false;
    }

    if (phoneNumber.isEmpty) {
      phoneError = "Phone number is required";
      isValid = false;
    } else if (!RegExp(r"^\d{10}$").hasMatch(phoneNumber)) {
      phoneError = "Phone number must be 10 digits";
      isValid = false;
    }

    if (selectedState.isEmpty) {
      stateError = "Please select a state";
      isValid = false;
    }

    if (sourceReference.isEmpty) {
      sourceError = "Please select a source";
      isValid = false;
    } else if (sourceReference == "Other" && otherSource.isEmpty) {
      sourceError = "Please specify the source";
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // Fetch all form values
  Map<String, String> getFormData() {
    return {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "state": selectedState,
      "queries": queries,
      "sourceReference": sourceReference == "Other"
          ? otherSource
          : sourceReference,
    };
  }
}
