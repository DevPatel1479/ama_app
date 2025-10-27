import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:flutter/material.dart';

class QueryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  List<QueryModel> _queries = [];
  String? _nextPageCursor;
  // bool isFetchingMore = false;

  bool _isFetchingMore = false; // private
  bool get isFetchingMore => _isFetchingMore;

  bool get isLoading => _isLoading;
  List<QueryModel> get queries => _queries;
  String? get nextPageCursor => _nextPageCursor;

  set isFetchingMore(bool value) {
    if (_isFetchingMore == value) return;
    _isFetchingMore = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setQueries(List<QueryModel> newQueries, {String? nextCursor}) {
    _queries = newQueries;
    _nextPageCursor = nextCursor;
    notifyListeners();
  }

  void appendQueries(List<QueryModel> newQueries, {String? nextCursor}) {
    // Use queryId as unique key
    final existingIds = _queries.map((q) => q.id).toSet();

    final filteredNewQueries = newQueries
        .where((q) => !existingIds.contains(q.id))
        .toList();

    if (filteredNewQueries.isNotEmpty) {
      _queries.addAll(filteredNewQueries);
      _nextPageCursor = nextCursor;
      notifyListeners();
    }
  }

  // Raise a new query
  Future<void> raiseQuery({
    required BuildContext context,
    required String role,
    required String phone,
    required String name,
    required String queryText,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.post(Endpoints.raiseUserQuery, {
        'role': role,
        'phone': phone,
        "name": name,
        'query': queryText,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final allocAdv = data['data']['alloc_adv'] ?? "N/A";
        final allocAdvSecondary = data['data']['alloc_adv_secondary'] ?? "N/A";

        // ✅ Build notification title and body
        final nTitle = "Client Query";

        // Take first 2–3 words of queryText, then add ellipsis
        final queryPreview = queryText.split(" ").take(3).join(" ") + "...";

        final nBody =
            "$queryPreview\n\n"
            "Primary Advocate: $allocAdv\n"
            "Secondary Advocate: $allocAdvSecondary";

        // ✅ Send notification to all advocates
        await _apiService.post(Endpoints.sendNotificationToAllAdvocates, {
          "user_id":
              "${role}_${phone}", // or user_id from your app’s auth context
          "n_title": nTitle,
          "n_body": nBody,
        });

        showCustomMessage(context, data['message'], false);
      } else {
        showCustomMessage(
          context,
          data['message'] ?? 'Failed to submit query',
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, 'Something went wrong: $e', true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchQueries({
    required BuildContext context,
    required String role,
    required String phone,
    int limit = 10,
    String? lastDocId,
    bool append = false,
    bool reset = false,
  }) async {
    if (!append) _setLoading(true);

    try {
      String url = "";
      if (role == "admin") {
        url = "${Endpoints.getUserQuery}?limit=$limit";
      } else {
        url = "${Endpoints.getUserQuery}?role=${role}&limit=$limit";
      }
      print("url $url");
      if (lastDocId != null && lastDocId.isNotEmpty)
        url += "&lastDocId=$lastDocId";

      final response = await _apiService.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List rawQueries = data['queries'] as List<dynamic>;
        final List<QueryModel> fetchedQueries = [];

        for (final item in rawQueries) {
          try {
            // Defensive normalization of raw item
            final Map<String, dynamic> map = Map<String, dynamic>.from(
              item as Map,
            );

            // Ensure queryId exists (prefer backend queryId, else id)
            map['queryId'] = map['queryId'] ?? map['id'] ?? '';

            // Normalize submitted_at: could be int / string / Timestamp-like
            final dynamic submittedRaw =
                map['submitted_at'] ?? map['submittedAt'];
            if (submittedRaw is int) {
              map['submitted_at'] = submittedRaw;
            } else if (submittedRaw is String) {
              map['submitted_at'] = int.tryParse(submittedRaw) ?? 0;
            } else if (submittedRaw is Map &&
                submittedRaw.containsKey('_seconds')) {
              // Rare case: Timestamp-like map returned by some APIs
              map['submitted_at'] = (submittedRaw['_seconds'] is int)
                  ? submittedRaw['_seconds']
                  : int.tryParse(submittedRaw['_seconds'].toString()) ?? 0;
            } else {
              map['submitted_at'] = 0;
            }

            // Normalize optional string fields that sometimes come as numbers
            if (map.containsKey('phone'))
              map['phone'] = map['phone']?.toString();
            if (map.containsKey('role')) map['role'] = map['role']?.toString();
            if (map.containsKey('parentDocId')) {
              map['parentDocId'] = map['parentDocId']?.toString();
            }
            if (map.containsKey('path')) map['path'] = map['path']?.toString();
            if (map.containsKey('remarks'))
              map['remarks'] = map['remarks']?.toString();

            // Normalize resolved_by if exists
            if (map.containsKey('resolved_by') && map['resolved_by'] is Map) {
              final resolved = Map<String, dynamic>.from(map['resolved_by']);
              if (resolved.containsKey('phone'))
                resolved['phone'] = resolved['phone']?.toString();
              if (resolved.containsKey('role'))
                resolved['role'] = resolved['role']?.toString();
              if (resolved.containsKey('name'))
                resolved['name'] = resolved['name']?.toString();
              map['resolved_by'] = resolved;
            }

            // Now safe to build model
            final model = QueryModel.fromJson(map);
            fetchedQueries.add(model);
          } catch (e, st) {
            // log and skip bad item (prevents whole fetch from failing)
            print("Failed to parse one query item: $e");
            print("RAW ITEM: $item");
            print(st);
          }
        }

        // Convert nextPageCursor to string safely (API returns int)
        final dynamic rawCursor = data['nextPageCursor'];
        final String? nextCursorStr = rawCursor == null
            ? null
            : rawCursor.toString();

        if (append) {
          appendQueries(fetchedQueries, nextCursor: nextCursorStr);
        } else {
          _setQueries(fetchedQueries, nextCursor: nextCursorStr);
        }
      } else {
        print("error ... ");
        // optionally showCustomMessage(...)
      }
    } catch (e) {
      print("Error this  : $e");
      showCustomMessage(context, 'Something went wrong: $e', true);
    } finally {
      if (!append) _setLoading(false);
    }
  }
}
