import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/query_model.dart';
import 'package:flutter/material.dart';

class QueryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String _activeStatus = 'pending'; // default
  bool _isLoading = false;

  bool _isFileDisputerLoading = false;

  bool get isFileDisputeLoading => _isFileDisputerLoading;

  final Map<String, int> _lastUsedLimitByStatus = {
    'pending': 10,
    'resolved': 10,
  };
  // Single public view - this will mirror the active status cache
  List<QueryModel> _queries = [];
  String? _nextPageCursor;

  // Per-status caches
  final Map<String, List<QueryModel>> _cacheByStatus = {
    'pending': [],
    'resolved': [],
  };
  final Map<String, String?> _nextCursorByStatus = {
    'pending': null,
    'resolved': null,
  };

  int _lastUsedLimit = 10;

  bool _isFetchingMore = false; // private
  bool get isFetchingMore => _isFetchingMore;

  bool get isLoading => _isLoading;
  List<QueryModel> get queries => _queries;
  String? get nextPageCursor => _nextPageCursor;

  // helpful getters if UI wants explicit lists
  List<QueryModel> get pendingQueries => _cacheByStatus['pending']!;
  List<QueryModel> get resolvedQueries => _cacheByStatus['resolved']!;

  set isFetchingMore(bool value) {
    if (_isFetchingMore == value) return;
    _isFetchingMore = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Internal: set the active view (mirrors the selected status cache to public fields)
  void _setActiveViewFromCache(String status) {
    _activeStatus = status;
    final list = _cacheByStatus[status] ?? [];
    _queries = List<QueryModel>.from(list);
    _nextPageCursor = _nextCursorByStatus[status];
    notifyListeners();
  }

  // Set queries for a given status (replace)
  void _setQueriesForStatus(
    String status,
    List<QueryModel> newQueries, {
    String? nextCursor,
  }) {
    _cacheByStatus[status] = List<QueryModel>.from(newQueries);
    _nextCursorByStatus[status] = nextCursor;
    // Also mirror to public view for UI that uses provider.queries
    _setActiveViewFromCache(status);
  }

  // Append queries for a given status (pagination)
  void _appendQueriesForStatus(
    String status,
    List<QueryModel> newQueries, {
    String? nextCursor,
  }) {
    final existing = _cacheByStatus[status] ?? [];
    final existingIds = existing.map((q) => q.id).toSet();
    final filtered = newQueries
        .where((q) => !existingIds.contains(q.id))
        .toList();
    if (filtered.isNotEmpty) {
      existing.addAll(filtered);
      _cacheByStatus[status] = existing;
      _nextCursorByStatus[status] = nextCursor;
      // If the UI currently showing this status, mirror it
      _setActiveViewFromCache(status);
    } else {
      // still update cursor even if no new items
      _nextCursorByStatus[status] = nextCursor;
      if ((_cacheByStatus[status] ?? []).isNotEmpty) {
        _setActiveViewFromCache(status);
      }
    }
  }

  // Merge lists helper (keeps unique by id and sorts by submittedAt desc)
  List<QueryModel> _mergeQueryLists(
    List<QueryModel> oldList,
    List<QueryModel> newList,
  ) {
    final Map<String, QueryModel> mergedMap = {};

    for (final q in oldList) {
      mergedMap[q.id] = q;
    }
    for (final q in newList) {
      mergedMap[q.id] = q;
    }

    final merged = mergedMap.values.toList();
    merged.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return merged;
  }

  // Raise a new query (unchanged)
  Future<bool> raiseQuery({
    required BuildContext context,
    required String role,
    required String phone,
    required String name,
    required String queryText,
    bool? fileDispute,
    String? selectedService,
  }) async {
    _setLoading(true);
    try {
      if (fileDispute != null && fileDispute == true) {
        final userId = "${role}_$phone";

        _isFileDisputerLoading = true;
        notifyListeners();

        final response = await _apiService.post(Endpoints.fileDispute, {
          "user_id": userId,
          "selected_service": selectedService,
          "query": queryText,
          "name": name,
        });
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          _isFileDisputerLoading = false;
          notifyListeners();
          showCustomMessage(context, data['message'], false);
          return true;
        } else {
          _isFileDisputerLoading = false;
          notifyListeners();
          showCustomMessage(
            context,
            data['message'] ?? 'Failed to file dispute',
            true,
          );
          return false;
        }
      } else {
        final response = await _apiService.post(Endpoints.raiseUserQuery, {
          'role': role,
          'phone': phone,
          "name": name,
          'query': queryText,
        });

        final data = jsonDecode(response.body);

        if (response.statusCode == 201 && data['success'] == true) {
          final allocAdv = data['data']['alloc_adv'] ?? "N/A";
          final allocAdvSecondary =
              data['data']['alloc_adv_secondary'] ?? "N/A";

          final nTitle = "Client Query";
          final queryPreview = queryText.split(" ").take(3).join(" ") + "...";
          final nBody =
              "$queryPreview\n\n"
              "Primary Advocate: $allocAdv\n"
              "Secondary Advocate: $allocAdvSecondary";

          await _apiService.post(Endpoints.sendNotificationToAllAdvocates, {
            "user_id": "${role}_${phone}",
            "n_title": nTitle,
            "n_body": nBody,
          });

          // showCustomMessage(context, data['message'], false);
          return true;
        } else {
          showCustomMessage(
            context,
            data['message'] ?? 'Failed to submit query',
            true,
          );
          return false;
        }
      }
    } catch (e) {
      showCustomMessage(context, 'Something went wrong: $e', true);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch single page and parse results (pass status through)
  Future<Map<String, dynamic>> _fetchPageFromApi({
    required String role,
    required String phone,
    required int limit,
    String? lastDocId,
    String? status,
  }) async {
    String url = "";
    if (role == "admin" || role == "advocate") {
      url = "${Endpoints.getUserQuery}?limit=$limit";
    } else {
      url = "${Endpoints.getUserQuery}?role=$role&phone=$phone&limit=$limit";
    }

    if (status != null && status.isNotEmpty) {
      url += "&status=$status";
    }

    if (lastDocId != null && lastDocId.isNotEmpty) {
      url += "&lastSubmittedAt=$lastDocId";
    }

    final response = await _apiService.get(url);
    final data = jsonDecode(response.body);

    final List<QueryModel> pageQueries = [];
    String? nextCursor;

    if (response.statusCode == 200 && data['success'] == true) {
      final List rawQueries = data['queries'] as List<dynamic>;
      for (final item in rawQueries) {
        try {
          final Map<String, dynamic> map = Map<String, dynamic>.from(
            item as Map,
          );
          final rawQueryId = (map['queryId'] ?? map['id'] ?? '').toString();
          map['queryId'] = rawQueryId;
          map['id'] = (map['id'] ?? rawQueryId).toString();

          final dynamic submittedRaw =
              map['submitted_at'] ?? map['submittedAt'];
          if (submittedRaw is int) {
            map['submitted_at'] = submittedRaw;
          } else if (submittedRaw is String) {
            map['submitted_at'] = int.tryParse(submittedRaw) ?? 0;
          } else if (submittedRaw is Map &&
              submittedRaw.containsKey('_seconds')) {
            map['submitted_at'] = (submittedRaw['_seconds'] is int)
                ? submittedRaw['_seconds']
                : int.tryParse(submittedRaw['_seconds'].toString()) ?? 0;
          } else {
            map['submitted_at'] = 0;
          }

          if (map.containsKey('phone')) map['phone'] = map['phone']?.toString();
          if (map.containsKey('role')) map['role'] = map['role']?.toString();
          if (map.containsKey('parentDocId')) {
            map['parentDocId'] = map['parentDocId']?.toString();
          }
          if (map.containsKey('path')) map['path'] = map['path']?.toString();
          if (map.containsKey('remarks'))
            map['remarks'] = map['remarks']?.toString();

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

          final model = QueryModel.fromJson(map);
          pageQueries.add(model);
        } catch (e) {
          debugPrint("⚠️ Failed to parse one query item: $e");
        }
      }

      final dynamic rawCursor = data['nextPageCursor'];
      nextCursor = rawCursor == null ? null : rawCursor.toString();
    } else {
      debugPrint("❌ Error fetching page: ${data['message']}");
    }

    return {
      'queries': pageQueries,
      'nextCursor': nextCursor,
      'success': response.statusCode == 200 && data['success'] == true,
    };
  }

  // Main fetch function (now always passes status to API and stores per-status)
  Future<void> fetchQueries({
    required BuildContext context,
    required String role,
    required String phone,
    int limit = 10,
    String? lastDocId,
    bool append = false,
    bool reset = false,
    String? status, // must pass 'pending' or 'resolved' from UI
  }) async {
    if (!append) _setLoading(true);
    final effectiveStatus = (status == null || status.isEmpty)
        ? 'pending'
        : status;
    _lastUsedLimitByStatus[effectiveStatus] = limit;

    // guard: if status not provided default to 'pending' (you can change this)

    try {
      // If reset and we already have items for that status, re-fetch enough pages to cover them
      if (reset && (_cacheByStatus[effectiveStatus]?.isNotEmpty ?? false)) {
        // Re-fetch the first N pages using remembered limit, no merging with old cache
        final storedLimit = _lastUsedLimitByStatus[effectiveStatus] ?? limit;
        final pagesNeeded =
            (_cacheByStatus[effectiveStatus]!.length / storedLimit).ceil();

        String? cursor;
        List<QueryModel> accumulated = [];
        String? finalNextCursor;

        for (int i = 0; i < pagesNeeded; i++) {
          final result = await _fetchPageFromApi(
            role: role,
            phone: phone,
            limit: storedLimit,
            lastDocId: cursor,
            status: effectiveStatus,
          );
          if (result['success'] != true) break;

          final pageItems = (result['queries'] as List<QueryModel>);
          accumulated.addAll(pageItems);
          finalNextCursor = result['nextCursor'] as String?;
          cursor = finalNextCursor;
          if (cursor == null) break;
        }

        // ✅ Instead of merging, replace — removes stale (wrong-status) items
        _setQueriesForStatus(
          effectiveStatus,
          accumulated,
          nextCursor: finalNextCursor,
        );
      } else {
        // single-page (append or replace)
        final result = await _fetchPageFromApi(
          role: role,
          phone: phone,
          limit: limit,
          lastDocId: lastDocId,
          status: effectiveStatus,
        );

        if (result['success'] == true) {
          final fetchedQueries = result['queries'] as List<QueryModel>;
          final nextCursorStr = result['nextCursor'] as String?;

          if (reset) {
            // merge into current cache for this status
            final merged = _mergeQueryLists(
              _cacheByStatus[effectiveStatus]!,
              fetchedQueries,
            );
            _setQueriesForStatus(
              effectiveStatus,
              merged,
              nextCursor: nextCursorStr,
            );
          } else if (append) {
            _appendQueriesForStatus(
              effectiveStatus,
              fetchedQueries,
              nextCursor: nextCursorStr,
            );
          } else {
            _setQueriesForStatus(
              effectiveStatus,
              fetchedQueries,
              nextCursor: nextCursorStr,
            );
          }
        } else {
          debugPrint("❌ Error fetching queries (single-page) ");
        }
      }
    } catch (e) {
      debugPrint("Error fetching queries: $e");
      showCustomMessage(context, 'Something went wrong: $e', true);
    } finally {
      if (!append) _setLoading(false);
    }
  }

  // Optional helper: clear caches (useful when logging out or switching user)
  void clearAllCaches({String activeStatus = 'pending'}) {
    _cacheByStatus['pending'] = [];
    _cacheByStatus['resolved'] = [];

    _nextCursorByStatus['pending'] = null;
    _nextCursorByStatus['resolved'] = null;

    // Mirror active view as empty so UI updates immediately
    _activeStatus = activeStatus;
    _queries = [];
    _nextPageCursor = null;

    // Reset flags that could block fetching
    _isFetchingMore = false;
    _isLoading = false;

    notifyListeners();
  }

  // Upsert a full QueryModel into the cache for its status and remove from other
  void upsertQueryInCache(QueryModel q) {
    final status = (q.status ?? 'pending');
    final other = status == 'pending' ? 'resolved' : 'pending';

    // Remove from other cache (if present)
    _cacheByStatus[other] = (_cacheByStatus[other] ?? [])
        .where((x) => x.id != q.id)
        .toList();

    final list = _cacheByStatus[status] ?? [];
    final idx = list.indexWhere((x) => x.id == q.id);
    if (idx >= 0) {
      list[idx] = q;
    } else {
      list.insert(0, q); // insert newest-first
    }
    _cacheByStatus[status] = list;

    // if UI currently showing this status, mirror it; otherwise just keep cache
    if (_activeStatus == status) {
      _setActiveViewFromCache(status);
    } else {
      notifyListeners();
    }
  }

  // Remove by id from all caches
  void removeQueryById(String id) {
    print("removing query with id $id");
    var changed = false;
    _cacheByStatus.forEach((k, list) {
      final before = list.length;
      list.removeWhere((x) => x.id == id);
      if (list.length != before) changed = true;
      _cacheByStatus[k] = list;
    });
    if (changed) {
      // mirror current active cache so UI updates
      _setActiveViewFromCache(_activeStatus);
    }
  }

  // Move an item locally to a new status (optimistic update)
  void moveQueryToStatusLocally(
    String id,
    String newStatus,
    QueryModel? updatedModel,
  ) {
    // Remove from both caches then add to newStatus cache
    removeQueryById(id);
    if (updatedModel != null) {
      upsertQueryInCache(updatedModel);
    } else {
      // if no model provided, just mirror active cache (server will provide data)
      _setActiveViewFromCache(_activeStatus);
    }
  }
}
