import 'dart:convert';

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/weekly_client_count_model.dart';
import 'package:flutter/material.dart';

class WeeklyClientCountProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  bool get loading => _loading;

  WeeklyClientCountModel? _weeklyClientCount;
  WeeklyClientCountModel? get weeklyClientCount => _weeklyClientCount;

  String? _error;
  String? get error => _error;

  // Fetch weekly client count
  Future<void> fetchWeeklyClientCount() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        Endpoints.getWeeklyClientsCount, // replace with your endpoint
        {}, // empty request body
      );

      if (response.statusCode == 200) {
        _weeklyClientCount = WeeklyClientCountModel.fromJson(
          response.body.isNotEmpty
              ? Map<String, dynamic>.from(jsonDecode(response.body))
              : {},
        );
      } else {
        _error = "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
