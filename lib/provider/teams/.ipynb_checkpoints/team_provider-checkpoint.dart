import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/models/team_member_model.dart';
import 'package:flutter/material.dart';

class TeamProvider extends ChangeNotifier {
  final ApiService apiService;

  TeamProvider({required this.apiService});

  List<TeamMember> _members = [];
  List<TeamMember> get members => _members;

  int _page = 1;
  int _limit = 10;
  int _totalPages = 1;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Fetch team members with pagination
  Future<void> fetchTeam({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _members.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = '${Endpoints.getTeamMembers}?page=$_page&limit=$_limit';
      final response = await apiService.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Extract data list from API response
        final List<dynamic> dataList = jsonData['data'] ?? [];

        // Map to TeamMember model
        final List<TeamMember> fetchedMembers = dataList
            .map((e) => TeamMember.fromJson(e))
            .toList();

        _members.addAll(fetchedMembers);

        _totalPages = jsonData['totalPages'] ?? 1;
        _hasMore = _page < _totalPages;
        _page++;
      } else {
        throw Exception(
          'Failed to load team data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching team: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
