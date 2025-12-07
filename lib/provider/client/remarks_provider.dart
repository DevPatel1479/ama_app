import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/remark_response_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class RemarksProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RemarkItem> _remarks = [];
  List<RemarkItem> get remarks => _remarks;

  // --- Fetch remarks ---
  Future<void> fetchRemarks(String baseUrl, String phone) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Endpoints.clientRemarks(phone);
      final Response res = await _apiService.get(url);

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final remarkResponse = RemarkResponse.fromJson(jsonData);

        if (remarkResponse.success) {
          // sorted latest first (backend already sorted but safe)
          _remarks = remarkResponse.data;
        } else {
          _remarks = [];
          _errorMessage = remarkResponse.message;
        }
      } else {
        _errorMessage =
            "Server Error: ${res.statusCode}. Please try again later.";
        _remarks = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _remarks = [];
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _remarks = [];
    _errorMessage = null;
    _loading = false;
    notifyListeners();
  }
}
