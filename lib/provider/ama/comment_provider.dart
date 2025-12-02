import 'dart:convert';
import 'package:ama_legal_solutions/api/endpoints.dart';
import 'package:ama_legal_solutions/custom_messages_widgets/custom_flushbar_message.dart';
import 'package:ama_legal_solutions/models/comments_model.dart';

import 'package:flutter/material.dart';

import 'package:ama_legal_solutions/api/api_service.dart';

class CommentProvider extends ChangeNotifier {
  final ApiService apiService;

  CommentProvider({required this.apiService});

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _lastVisible;

  int _commentsCount = 0;
  int get commentsCount => _commentsCount;

  void clearExistingComments() {
    comments.clear();
    notifyListeners();
  }

  /// Fetch comments for a question (supports pagination)
  Future<void> fetchComments(
    String questionId, {
    int limit = 10,
    bool reset = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (reset) {
        _comments.clear();
        _lastVisible = null;
        _hasMore = true;
      }
      Map<String, dynamic> body = {"questionId": questionId, "limit": limit};
      // Build URL with query params
      String url = Endpoints.getComments;
      Map<String, dynamic> lastVisibleData = {};
      if (_lastVisible != null) lastVisibleData = {"lastVisible": _lastVisible};

      if (lastVisibleData.isNotEmpty) {
        body.addAll(lastVisibleData);
      }

      final response = await apiService.post(url, body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final List<Comment> fetchedComments = (data['comments'] as List)
          .map((e) => Comment.fromMap(e))
          .toList();

      if (fetchedComments.isNotEmpty) {
        _lastVisible = data['lastVisible'];
        _comments.addAll(fetchedComments);
      }

      if (fetchedComments.length < limit) _hasMore = false;
    } catch (e) {
      // print('Error fetching comments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add a comment using ApiService
  Future<bool> postComment({
    required BuildContext context,
    required String questionId,
    required String content,
    required String commentedBy,
    String? profileImgUrl,
    String? userRole,
    String? phone,
  }) async {
    // print(profileImgUrl);
    // print(userRole);
    // print(phone);
    // print(commentedBy);

    try {
      final body = {
        'content': content, 
        'commentedBy': commentedBy,
        'profileImgUrl': profileImgUrl,
        'userRole': userRole,
        'phone': phone,
        'questionId': questionId,
      };

      final url = Endpoints.addComments;
      final response = await apiService.post(url, body);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Add locally for instant UI update
      _comments.insert(0, Comment.fromMap(data));
      _commentsCount++; // update count immediately
      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomMessage(context, "Comment posted Successfully", false);
        await Future.delayed(Duration(seconds: 1));
      } else {
        showCustomMessage(context, "Failed to post comment", true);
        await Future.delayed(Duration(seconds: 1));
      }

      notifyListeners();
    } catch (e) {
      showCustomMessage(
        context,
        "Comment limit reached !! Try again after 4 hours",
        true,
      );
      // print('Error posting comment: $e');
      return false;
    }
    return true;
  }

  /// Fetch the total comments count for a question
  Future<void> fetchCommentsCount(String questionId) async {
    try {
      final url = Endpoints.getCommentsCount(questionId);
      final response = await apiService.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _commentsCount = data['commentsCount'] ?? 0;
      notifyListeners();
    } catch (e) {
      // print('Error fetching comments count: $e');
    }
  }

  void clear() {
    _comments.clear();
    _lastVisible = null;
    _hasMore = true;
    _commentsCount = 0;
    notifyListeners();
  }
}
