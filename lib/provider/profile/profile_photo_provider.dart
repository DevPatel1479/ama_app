import 'dart:io';
import 'dart:convert';
import 'package:ama_legal_solutions/db/storage/local/local_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _profilePhotoUrl;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _hasProfilePhoto = false; // New state

  String? get profilePhotoUrl => _profilePhotoUrl;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get hasProfilePhoto => _hasProfilePhoto;

  /// Fetch profile photo
  Future<void> fetchProfilePhoto(
    BuildContext context, {
    required String phone,
    required String role,
    bool forceRefresh = false, // new flag
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cachedUrl = await LocalStorageHelper.getString('profile_photo_url');

      if (!forceRefresh && cachedUrl != null && cachedUrl.startsWith('https')) {
        _profilePhotoUrl = cachedUrl;
        _hasProfilePhoto = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.post(Endpoints.getProfilePhoto, {
        'phone': phone,
        'role': role,
      });

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['profile_img'] != null) {
        _profilePhotoUrl = data['profile_img'];
        _hasProfilePhoto = true;

        // Save to local storage
        await LocalStorageHelper.saveString(
          'profile_photo_url',
          _profilePhotoUrl!,
        );
      } else {
        _profilePhotoUrl = null;
        _hasProfilePhoto = false;
        showCustomMessage(
          context,
          data['message'] ?? 'Profile photo not found. Using default icon.',
          true,
        );
      }
    } catch (e) {
      _profilePhotoUrl = null;
      _hasProfilePhoto = false;
      showCustomMessage(context, e.toString(), true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload new profile photo
  Future<void> uploadProfilePhoto(
    BuildContext context, {
    required String phone,
    required String role,
    required File photo,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Endpoints.uploadProfilePhoto),
      );

      request.fields['phone'] = phone;
      request.fields['role'] = role;

      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', photo.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['profile_img'] != null) {
        _profilePhotoUrl = data['profile_img'];
        _hasProfilePhoto = true;

        await LocalStorageHelper.saveString(
          'profile_photo_url',
          _profilePhotoUrl!,
        );
        await fetchProfilePhoto(
          context,
          phone: phone,
          role: role,
          forceRefresh: true, // bypass cache
        );
        showCustomMessage(
          context,
          'Profile photo uploaded successfully!',
          false,
        );
      } else {
        _hasProfilePhoto = false;
        showCustomMessage(
          context,
          data['message'] ?? 'Failed to upload profile photo',
          true,
        );
      }
    } catch (e) {
      _hasProfilePhoto = false;
      showCustomMessage(context, e.toString(), true);
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Update (replace) profile photo
  Future<void> updateProfilePhoto(
    BuildContext context, {
    required String phone,
    required String role,
    required File newPhoto,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Endpoints.updateProfilePhoto),
      );

      request.fields['phone'] = phone;
      request.fields['role'] = role;

      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', newPhoto.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['profile_img'] != null) {
        _profilePhotoUrl = data['profile_img'];
        _hasProfilePhoto = true;
        print("updated profile photo url $_profilePhotoUrl");
        await LocalStorageHelper.saveString(
          'profile_photo_url',
          _profilePhotoUrl!,
        );

        showCustomMessage(
          context,
          'Profile photo updated successfully!',
          false,
        );
      } else {
        _hasProfilePhoto = false;
        showCustomMessage(
          context,
          data['message'] ?? 'Failed to update profile photo',
          true,
        );
      }
    } catch (e) {
      _hasProfilePhoto = false;
      showCustomMessage(context, e.toString(), true);
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
