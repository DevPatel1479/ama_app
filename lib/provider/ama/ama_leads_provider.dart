// ama_leads_provider.dart
import 'dart:async' show Timer, StreamSubscription;
import 'dart:convert';
import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/firebase/ama_crm_firebase.dart';
import 'package:ama_legal_solutions/models/ama_lead_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/material.dart';

class AmaLeadsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  FirebaseFirestore? _firestore;

  List<AmaLeadModel> _leads = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _nextCursorId;
  String _currentName = '';
  String _search = '';
  Timer? _debounce;
  StreamSubscription? _realtimeSub;

  // track if first successful load happened
  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;

  List<AmaLeadModel> get leads => _leads;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String get search => _search;

  /// Debounced search (resets to first page)
  void setSearch(String value, {bool isAdmin = false}) {
    _search = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (isAdmin) {
        fetchAdminLeads(reset: true, search: _search);
      } else {
        fetchLeads(name: _currentName, search: _search, reset: true);
      }
    });
  }

  Future<void> ensureCrmFirebaseReady() async {
    _firestore ??= await AmaCrmFirebase.getFirestore();
  }

  /// General fetch for assigned user (reset=true clears list)
  Future<void> fetchLeads({
    required String name,
    int limit = 20,
    String? search,
    bool reset = true,
  }) async {
    // prevent concurrent overlapping fetches for same mode
    if (_isLoading && reset == false) return;

    _isLoading = true;
    _currentName = name;
    if (search != null) _search = search;

    if (reset) {
      _hasMore = true;
      _nextCursorId = null;
      _leads.clear();
    }

    notifyListeners();

    try {
      final url = Endpoints.fetchAmaLeads(
        name,
        limit,
        reset ? null : _nextCursorId,
        search: _search,
      );

      final res = await _apiService.get(url);
      final decoded = jsonDecode(res.body);
      print("Fetch AMA Leads Response: $decoded");
      final List list = decoded['data'] ?? [];
      final fetched = list.map((e) => AmaLeadModel.fromJson(e)).toList();

      if (reset) {
        _leads = fetched;
      } else {
        _leads.addAll(fetched);
      }

      _nextCursorId = decoded['nextCursorId'];
      _hasMore = decoded['hasMore'] ?? false;
    } catch (e) {
      debugPrint("Fetch AMA Leads Error: $e");
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Pagination for non-admin flow
  Future<void> fetchMore({int limit = 20}) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final url = Endpoints.fetchAmaLeads(
        _currentName,
        limit,
        _nextCursorId,
        search: _search,
      );

      final res = await _apiService.get(url);
      final decoded = jsonDecode(res.body);

      final List list = decoded['data'] ?? [];
      _leads.addAll(list.map((e) => AmaLeadModel.fromJson(e)).toList());

      _nextCursorId = decoded['nextCursorId'];
      _hasMore = decoded['hasMore'] ?? false;
    } catch (e) {
      debugPrint("Fetch More AMA Leads Error: $e");
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// ----------------- ADMIN METHODS (REVERTED & WORKABLE) -----------------

  /// Fetch leads as admin (fetches ALL leads). Works like earlier code.
  Future<void> fetchAdminLeads({
    int limit = 20,
    String? search,
    bool reset = true,
  }) async {
    if (_isLoading && reset == false) return;

    _isLoading = true;
    if (search != null) _search = search;

    if (reset) {
      _hasMore = true;
      _nextCursorId = null;
      _leads.clear();
    }

    notifyListeners();

    try {
      final url = Endpoints.fetchAmaLeadsAdmin(
        limit,
        reset ? null : _nextCursorId,
        search: _search,
      );
      final res = await _apiService.get(url);
      final decoded = jsonDecode(res.body);

      final List list = decoded['data'] ?? [];
      final fetched = list.map((e) => AmaLeadModel.fromJson(e)).toList();

      if (reset) {
        _leads = fetched;
      } else {
        _leads.addAll(fetched);
      }

      _nextCursorId = decoded['nextCursorId'];
      _hasMore = decoded['hasMore'] ?? false;
    } catch (e) {
      debugPrint("Fetch Admin AMA Leads Error: $e");
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  /// Pagination for admin mode
  Future<void> fetchMoreAdmin({int limit = 20}) async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final url = Endpoints.fetchAmaLeadsAdmin(
        limit,
        _nextCursorId,
        search: _search,
      );
      final res = await _apiService.get(url);
      final decoded = jsonDecode(res.body);

      final List list = decoded['data'] ?? [];
      _leads.addAll(list.map((e) => AmaLeadModel.fromJson(e)).toList());

      _nextCursorId = decoded['nextCursorId'];
      _hasMore = decoded['hasMore'] ?? false;
    } catch (e) {
      debugPrint("Fetch More Admin AMA Leads Error: $e");
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// Reset provider fully
  void reset() {
    _leads.clear();
    _nextCursorId = null;
    _hasMore = true;
    _isLoading = false;
    _isFetchingMore = false;
    _hasLoadedOnce = false;
    _search = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _realtimeSub?.cancel();
    super.dispose();
  }
}
