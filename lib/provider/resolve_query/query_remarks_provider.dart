import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/query_remarks_model.dart';
import 'package:flutter/material.dart';

class QueryRemarksProvider with ChangeNotifier {
  final ApiService apiService;

  QueryRemarksProvider({required this.apiService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  QueryRemarksResponse? _response;
  QueryRemarksResponse? get response => _response;

  Future<bool> updateRemarks({
    required String queryId,
    String? parentDocId,
    required String remarks,
    String? operatorRole,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final body = {
        "queryId": queryId,
        "parentDocId": parentDocId,
        "remarks": remarks,
        "operatorRole": operatorRole,
      };

      final res = await apiService.patch(Endpoints.updateQueryRemarks, body);

      final jsonData = jsonDecode(res.body);

      if (res.statusCode == 200 && jsonData["success"] == true) {
        _response = QueryRemarksResponse.fromJson(jsonData);
        _successMessage = jsonData["message"];

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = jsonData["message"] ?? "Something went wrong";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
