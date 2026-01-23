import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/delete_question_response.dart';
import 'package:flutter/material.dart';

class DeleteQuestionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  String? _error;
  String? get error => _error;

  DeleteQuestionResponse? _response;
  DeleteQuestionResponse? get response => _response;

  /// DELETE QUESTION
  Future<bool> deleteQuestion({
    required String questionId,
    required String role,
  }) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      final body = {"questionId": questionId, "role": role};

      final res = await _apiService.delete(Endpoints.deleteQuestion, body);

      final data = jsonDecode(res.body);

      _response = DeleteQuestionResponse.fromJson(data);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _isDeleting = false;
        notifyListeners();
        return true;
      } else {
        _error = data["message"] ?? "Delete failed";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isDeleting = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _response = null;
    _error = null;
    notifyListeners();
  }
}
