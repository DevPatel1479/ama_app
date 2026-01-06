import 'dart:convert';

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
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

  // Loading state
  bool isLoading = false;

  // API result message
  String? resultMessage;

  bool isError = false;

  String countryCode = "+91";

  String get getSelectedCountryCode => countryCode;

  String normalizeCountryCode(String code) {
    return code.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void setCountryCode(String code) {
    countryCode = code;
    notifyListeners();
  }

  void setMessage(String message, bool error) {
    resultMessage = message;
    isError = error;
    notifyListeners();
  }

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
      "name": fullName,
      "email": email,
      "phone": phoneNumber,
      "state": selectedState,
      "query": queries,
      "source": sourceReference == "Other" ? otherSource : sourceReference,
      "role": "user",
    };
  }

  Future<void> submitSignup() async {
    isLoading = true;
    resultMessage = null;
    notifyListeners();
    // print("calling signup ...");
    try {
      final response = await ApiService().post(
        Endpoints.signup,
        getFormData(), // ✅ Use this, since it's within the same class
      );
      // print("Final API RESPONSE ===> ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setMessage("Signup successful!", false);
      } else {
        // Show message from server response, like "User already exists"
        final body = jsonDecode(response.body);
        setMessage(body['message'] ?? "Unknown error", true);
      }
    } catch (e) {
      setMessage("Signup failed: ${e.toString()}", true);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
