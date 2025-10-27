import 'dart:convert';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/models/resolve_query_model.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';

class ResolveQueryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> resolveQuery({
    required BuildContext context,
    required String operatorRole,
    required String operatorName,
    String? operatorPhone,
    required String queryId,
    String? parentDocId,
    String? remarks,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(
        Endpoints.markResolvedQuery, // replace with your actual endpoint
        {
          'operatorRole': operatorRole,
          'operatorName': operatorName,
          'operatorPhone': operatorPhone,
          'queryId': queryId,
          'parentDocId': parentDocId,
          'remarks': remarks,
        },
      );

      final data = jsonDecode(response.body);
      String apiMessage = data["message"] ?? "";
      if (apiMessage.contains("Query is already resolved.")) {
        showCustomMessage(context, apiMessage, true);
      } else {
        final result = ResolveQueryModel.fromJson(data);

        showCustomMessage(context, result.message, !result.success);
      }
    } catch (e) {
      showCustomMessage(context, 'Something went wrong: $e', true);
    } finally {
      _setLoading(false);
    }
  }
}
