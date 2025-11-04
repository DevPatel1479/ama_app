import 'dart:convert' show jsonDecode;

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  final ApiService _apiServices = ApiService();

  bool isLoading = false;
  double rating = 0.0;
  String comment = "";

  void setRating(double value) {
    rating = value;
    notifyListeners();
  }

  void setComment(String value) {
    comment = value;
    notifyListeners();
  }

  Future<bool> submitFeedback(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiServices.post(
        Endpoints.submitFeedback, // replace with your endpoint
        {"user_id": userId, "rate": rating, "feedback": comment},
      );
      final data = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();

      if (data['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
