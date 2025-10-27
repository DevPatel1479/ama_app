import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/answer_model.dart';

class AnswerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnswerModel? _answer;
  AnswerModel? get answer => _answer;

  /// Add or update answer
  Future<void> addOrUpdateAnswer({
    required BuildContext context,
    required String questionId,
    required String content,
    required String answeredBy,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(Endpoints.addAnswer(questionId), {
        "content": content,
        "answeredBy": answeredBy,
        "role": role,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['answer'] != null) {
        _answer = AnswerModel.fromJson(data['answer']);
        showCustomMessage(
          context,
          data['message'] ?? "Answer added successfully",
          false,
        );
      } else {
        showCustomMessage(
          context,
          data['error'] ?? "Failed to add answer",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, "Error: ${e.toString()}", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear stored answer
  void clearAnswer() {
    _answer = null;
    notifyListeners();
  }
}
