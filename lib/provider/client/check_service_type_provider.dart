// providers/check_service_type_provider.dart

import 'dart:convert';

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/check_service_type_response_model.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class CheckServiceTypeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  CheckServiceTypeResponseModel? _response;

  bool get isLoading => _isLoading;
  CheckServiceTypeResponseModel? get response => _response;
  bool get isLoanSettlement => _response?.isLoanSettlement ?? false;

  Future<bool> checkServiceType(BuildContext context, String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiResponse = await _apiService.get(
        Endpoints.checkServiceType(phone),
      );

      final Map<String, dynamic> jsonData = jsonDecode(apiResponse.body);

      _response = CheckServiceTypeResponseModel.fromJson(jsonData);

      if (!_response!.success) {
        _showError(context, _response!.message);
        return false;
      }

      return true;
    } catch (e) {
      _showError(context, e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _response = null;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}
