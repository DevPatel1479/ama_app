import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:ama_legal_solutions/models/leads_model.dart';
import 'package:ama_legal_solutions/models/update_user_response.dart';
import 'package:ama_legal_solutions/models/user_complete_info_model.dart';
import 'package:ama_legal_solutions/utils/global_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UserInfoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isFetching = false;
  bool _isUpdating = false;
  String? _errorMessage;

  UserCompleteInfoModel? _userInfo;
  bool get isFetching => _isFetching;
  bool get isUpdating => _isUpdating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserCompleteInfoModel? get userInfo => _userInfo;

  LeadsResponseModel? _leadsInfo;

  LeadsResponseModel? get leadsInfo => _leadsInfo;

  String? _error;
  String? get error => _error;

  Future<void> fetchUserInfo(
    BuildContext context,
    bool onlyBankInfoFetching,
  ) async {
    _userInfo = null;
  _leadsInfo = null;
  _error = null;
  _errorMessage = null;
  notifyListeners();
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
      // print(data);
      if (data["success"] == true) {
        _userInfo = UserCompleteInfoModel.fromJson(data["data"]);
        if (onlyBankInfoFetching == false) {
        } else {
          
        }
      } else {
        _error = data["message"] ?? "Failed to fetch";
        showCustomMessage(context, data["message"] ?? "Failed to fetch", true);
        notifyListeners();
      }
    } catch (e) {
      // print(e);
      _error = e.toString();
      notifyListeners();
      showCustomMessage(context, "Error: $e", true);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Get Lead by phone (GET /api/leads/:phone)
  Future<LeadsResponseModel> getLeadByPhone(BuildContext context) async {
    _isFetching = true;
    notifyListeners();

    try {
      final phone = await LocalStorageHelper.getString("userPhone");

      if (phone == null || phone.isEmpty) {
        showCustomMessage(context, "Phone not found", true);
        _isFetching = false;
        notifyListeners();
        return LeadsResponseModel(success: false, message: "Phone not found");
      }

      final Response response = await _apiService.get(
        Endpoints.getLeadByPhone(phone),
      );

      final data = jsonDecode(response.body);
      print("api data : $data");
      final leadResponse = LeadsResponseModel.fromJson(data);

      if (leadResponse.success && leadResponse.data != null) {
        _leadsInfo = leadResponse;
      } else {
        _errorMessage = leadResponse.message;
        showCustomMessage(context, _errorMessage!, true);
      }

      return leadResponse;
    } catch (e) {
      _errorMessage = e.toString();
      showCustomMessage(context, "Error: $_errorMessage", true);
      return LeadsResponseModel(
        success: false,
        message: _errorMessage ?? "Unknown error",
      );
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  /// ✅ Update user data (PUT /api/leads/update)
  Future<UpdateUserResponse> updateUserData(
    BuildContext context, {
    required String phone,
    String? name,
    String? email,
    String? state,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {"phone": phone};
      if (name != null && name.isNotEmpty) body["name"] = name;
      if (email != null && email.isNotEmpty) body["email"] = email;
      if (state != null && state.isNotEmpty) body["state"] = state;

      final Response response = await _apiService.put(
        Endpoints.updateUserData,
        body,
      );

      final data = jsonDecode(response.body);
      final updateResponse = UpdateUserResponse.fromJson(data);

      if (updateResponse.success) {
        // Update locally stored lead model (if already fetched)
        if (_leadsInfo?.data != null) {
          final updatedLead = _leadsInfo!.data!.copyWith(
            name: name ?? _leadsInfo!.data!.name,
            email: email ?? _leadsInfo!.data!.email,
            state: state ?? _leadsInfo!.data!.state,
          );

          _leadsInfo = LeadsResponseModel(
            success: true,
            message: updateResponse.message,
            data: updatedLead,
          );
          updateGlobalUserName(updatedLead.name);
          updateGlobalUserEmail(updatedLead.email);
          await LocalStorageHelper.saveString("userName", updatedLead.name!);
        }

        showCustomMessage(
          context,
          updateResponse.message.isNotEmpty
              ? updateResponse.message
              : "User updated successfully",
          false,
        );
      } else {
        _errorMessage = updateResponse.message;
        showCustomMessage(context, _errorMessage!, true);
      }

      return updateResponse;
    } catch (e) {
      _errorMessage = e.toString();
      showCustomMessage(context, "Error: $_errorMessage", true);
      return UpdateUserResponse(
        success: false,
        message: _errorMessage ?? "Unknown error",
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
