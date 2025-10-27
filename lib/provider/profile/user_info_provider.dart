import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/user_complete_info_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UserInfoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  UserCompleteInfoModel? _userInfo;

  bool get isLoading => _isLoading;
  UserCompleteInfoModel? get userInfo => _userInfo;

  Future<void> fetchUserInfo(
    BuildContext context,
    bool onlyBankInfoFetching,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final phone = await LocalStorageHelper.getString(
        "userPhone",
      ); // <-- await here
      if (phone == null || phone.isEmpty) {
        showCustomMessage(context, "Phone not found", true);
        _isLoading = false;
        notifyListeners();
        return;
      }

      final Response response = await _apiService.post(
        Endpoints.getUserCompleteInfo,
        {"phone": phone},
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        _userInfo = UserCompleteInfoModel.fromJson(data["data"]);
        if (onlyBankInfoFetching == false) {
          showCustomMessage(
            context,
            data["message"] ?? "Fetched successfully",
            false,
          );
        } else {
          showCustomMessage(
            context,
            "Bank details fetched successfully",
            false,
          );
        }
      } else {
        showCustomMessage(context, data["message"] ?? "Failed to fetch", true);
      }
    } catch (e) {
      print(e);
      showCustomMessage(context, "Error: $e", true);
    }

    _isLoading = false;
    notifyListeners();
  }
}
