// lib/provider/ama/question_provider.dart
import 'dart:async';
import 'dart:convert';

import 'package:ama_legal_solutions/api/api_service.dart';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionProvider extends ChangeNotifier {
  final ApiService apiService;

  QuestionProvider({required this.apiService});

  final List<Question> _questions = [];
  List<Question> get questions => List.unmodifiable(_questions);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastVisible;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Subscriptions for per-document realtime updates (used for lazily loaded docs)
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
  _docSubscriptions = {};

  /// --- Public API methods ---

  /// Fetch paginated questions from your REST API
  Future<void> fetchQuestions(
    BuildContext context, {
    bool reset = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    if (reset) {
      _lastVisible = null;
      _questions.clear();
      _hasMore = true;
    }

    try {
      String url = "${Endpoints.getAllQuestions}?limit=10";
      if (_lastVisible != null) url += "&lastVisible=$_lastVisible";

      final response = await apiService.get(url);
      final data = jsonDecode(response.body);

      if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
        final List<Question> fetchedQuestions = (data['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();

        // Add using upsert to avoid duplicates
        for (final q in fetchedQuestions) {
          _upsertLocal(q);
        }

        // Save cursor and hasMore
        _lastVisible = data['lastVisible'];
        _hasMore = data['lastVisible'] != null;

        // Start realtime doc subscriptions for newly fetched docs (so lazy-loaded docs also get realtime)
        final newIds = fetchedQuestions.map((q) => q.id).toList();
        _subscribeToDocIds(newIds);
      }
    } catch (e) {
      showCustomMessage(context, "Error fetching questions: $e", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch only (silently) used for background updates (no loading state)
  Future<void> fetchQuestionsSilently(
    BuildContext context, {
    bool reset = false,
  }) async {
    if (reset) {
      _lastVisible = null;
      _questions.clear();
      _hasMore = true;
    }

    try {
      String url = "${Endpoints.getAllQuestions}?limit=10";
      if (_lastVisible != null) url += "&lastVisible=$_lastVisible";

      final response = await apiService.get(url);
      final data = jsonDecode(response.body);

      if (data['questions'] != null && (data['questions'] as List).isNotEmpty) {
        final List<Question> fetchedQuestions = (data['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();

        for (final q in fetchedQuestions) {
          _upsertLocal(q);
        }

        _lastVisible = data['lastVisible'];
        _hasMore = data['lastVisible'] != null;

        final newIds = fetchedQuestions.map((q) => q.id).toList();
        _subscribeToDocIds(newIds);
      }
    } catch (_) {
      // silent
    } finally {
      notifyListeners();
    }
  }

  /// Create a new question
  Future<void> createQuestion(
    BuildContext context, {
    required String userId,
    required String userName,
    required String userRole,
    required String phone,
    String? profileImgUrl,
    required String content,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final body = {
        "userId": userId,
        "userName": userName,
        "userRole": userRole,
        "phone": phone,
        "profileImgUrl": profileImgUrl,
        "content": content,
      };

      final response = await apiService.post(Endpoints.createQuestion, body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final q = Question.fromJson(data);
        _questions.insert(0, q);
        // subscribe to this doc so realtime updates reflect immediately
        _subscribeToDocIds([q.id]);
        showCustomMessage(context, "Question added successfully", false);
      } else {
        final data = jsonDecode(response.body);
        showCustomMessage(
          context,
          data['error'] ?? "Failed to add question",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, "Error: $e", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add answer to a question
  Future<void> addAnswer(
    BuildContext context, {
    required String questionId,
    required String content,
    required String answeredBy,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final body = {"content": content, "answeredBy": answeredBy, "role": role};
      final response = await apiService.post(
        Endpoints.addAnswer(questionId),
        body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['answer'];
        final index = _questions.indexWhere((q) => q.id == questionId);
        if (index != -1) {
          _questions[index] = _questions[index].copyWith(
            answer: Answer.fromJson(data),
          );
        }
        showCustomMessage(context, "Answer added successfully", false);
      } else {
        final data = jsonDecode(response.body);
        showCustomMessage(
          context,
          data['error'] ?? "Failed to add answer",
          true,
        );
      }
    } catch (e) {
      showCustomMessage(context, "Error: $e", true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upsert a question to the local list (insert if not exists, update if exists)
  void _upsertLocal(Question q) {
    final idx = _questions.indexWhere((x) => x.id == q.id);
    if (idx == -1) {
      _questions.insert(0, q);
    } else {
      _questions[idx] = q;
    }
    // keep latest-first order by timestamp
    _questions.sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
  }

  /// Public upsert (notifying)
  void upsertQuestion(Question q) {
    _upsertLocal(q);
    notifyListeners();
  }

  /// Remove question by id
  void removeQuestionById(String id) {
    final before = _questions.length;
    _questions.removeWhere((q) => q.id == id);
    final after = _questions.length;
    if (after != before) {
      notifyListeners();
    }
    // if we had an active doc subscription for this id, cancel it
    _unsubscribeDocId(id);
  }

  /// --- Realtime per-document subscriptions for lazily loaded docs ---

  void _subscribeToDocIds(List<String> ids) {
    for (final id in ids) {
      if (id == null) continue;
      if (_docSubscriptions.containsKey(id)) continue; // already subscribed

      final sub = FirebaseFirestore.instance
          .collection('questions')
          .doc(id)
          .snapshots()
          .listen(
            (docSnap) {
              if (!docSnap.exists) {
                // doc deleted
                removeQuestionById(id);
                return;
              }

              final data = docSnap.data() ?? <String, dynamic>{};

              // Normalize fields similarly to when fetching from API
              final map = <String, dynamic>{
                'id': docSnap.id,
                'userId': data['userId'],
                'userName': data['userName'],
                'userRole': data['userRole'],
                'phone': data['phone'],
                'profileImgUrl': data['profileImgUrl'],
                'content': data['content'],
                'timestamp': _normalizeTimestampField(data['timestamp']),
                'answer': data['answer'],
                'commentsCount': data['commentsCount'] ?? 0,
              };

              try {
                final q = Question.fromJson(map);
                // upsert into local list and notify
                upsertQuestion(q);
              } catch (_) {
                // ignore parse error
              }
            },
            onError: (e) {
              // optional logging
            },
          );

      _docSubscriptions[id] = sub;
    }
  }

  void _unsubscribeDocId(String id) {
    final sub = _docSubscriptions.remove(id);
    sub?.cancel();
  }

  /// Cancel all doc subscriptions
  Future<void> _cancelAllDocSubscriptions() async {
    for (final sub in _docSubscriptions.values) {
      await sub.cancel();
    }
    _docSubscriptions.clear();
  }

  // Normalize a timestamp coming from Firestore (Timestamp or int in seconds/ms)
  int _normalizeTimestampField(dynamic ts) {
    if (ts == null) return 0;
    if (ts is int) {
      if (ts < 1000000000000) return ts * 1000;
      return ts;
    }
    try {
      // Firestore Timestamp
      final date = ts.toDate();
      return date.millisecondsSinceEpoch;
    } catch (_) {
      try {
        final d = (ts as num).toInt();
        if (d < 1000000000000) return d * 1000;
        return d;
      } catch (_) {
        return 0;
      }
    }
  }

  /// Must be called when provider is no longer used
  @override
  void dispose() {
    _cancelAllDocSubscriptions();
    super.dispose();
  }
}
