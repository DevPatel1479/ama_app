// lib/models/question_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String phone;
  final String? profileImgUrl;
  final String content;
  final int timestamp; // milliseconds since epoch
  final int commentsCount;
  final Answer? answer;

  Question({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.phone,
    this.profileImgUrl,

    required this.content,
    required this.timestamp,
    this.commentsCount = 0,
    this.answer,
  });

  /// Tolerant factory that accepts Map with different timestamp shapes:
  /// - Firestore Timestamp
  /// - int seconds OR milliseconds
  /// - string numeric (will try parse)
  factory Question.fromJson(Map<String, dynamic> json) {
    final ts = _parseTimestamp(json['timestamp']);
    return Question(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      userRole: (json['userRole'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profileImgUrl: json['profileImgUrl']?.toString(),

      content: (json['content'] ?? '').toString(),
      timestamp: ts,
      commentsCount: (json['commentsCount'] is int)
          ? json['commentsCount'] as int
          : int.tryParse((json['commentsCount'] ?? '0').toString()) ?? 0,
      answer: json['answer'] != null
          ? Answer.fromJson(Map<String, dynamic>.from(json['answer']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'phone': phone,
      'profileImgUrl': profileImgUrl,

      'content': content,
      'timestamp': timestamp,
      'commentsCount': commentsCount,
      'answer': answer?.toJson(),
    };
  }

  /// CopyWith lets provider update only the answer (or any other field)
  Question copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? phone,
    String? profileImgUrl,

    String? content,
    int? timestamp,
    int? commentsCount,
    Answer? answer,
  }) {
    return Question(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      phone: phone ?? this.phone,
      profileImgUrl: profileImgUrl ?? this.profileImgUrl,
      
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      commentsCount: commentsCount ?? this.commentsCount,
      answer: answer ?? this.answer,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, userName: $userName, content: ${content.substring(0, content.length > 30 ? 30 : content.length)})';
  }

  /// Helper: normalize timestamp into milliseconds since epoch
  static int _parseTimestamp(dynamic ts) {
    if (ts == null) return 0;
    // Firestore Timestamp
    try {
      if (ts is Timestamp) {
        return ts.toDate().millisecondsSinceEpoch;
      }
    } catch (_) {}
    // int (seconds or ms)
    if (ts is int) {
      // if looks like seconds (less than 1e12) convert to ms
      if (ts < 1000000000000) return ts * 1000;
      return ts;
    }
    // string numeric
    if (ts is String) {
      final cleaned = ts.trim();
      final parsed = int.tryParse(cleaned);
      if (parsed != null) {
        if (parsed < 1000000000000) return parsed * 1000;
        return parsed;
      }
      // maybe ISO date string
      try {
        final dt = DateTime.parse(cleaned);
        return dt.millisecondsSinceEpoch;
      } catch (_) {}
    }
    // fallback
    return 0;
  }
}

class Answer {
  final String content;
  final String answeredBy;
  final String role;
  final int timestamp; // ms since epoch

  Answer({
    required this.content,
    required this.answeredBy,
    required this.role,
    required this.timestamp,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    // some backends use 'answered_by' others 'answeredBy'
    final answeredByVal = json['answered_by'] ?? json['answeredBy'] ?? '';
    final roleVal = json['role'] ?? '';
    final contentVal = json['content'] ?? '';
    final ts = Question._parseTimestamp(json['timestamp']);

    return Answer(
      content: contentVal.toString(),
      answeredBy: answeredByVal.toString(),
      role: roleVal.toString(),
      timestamp: ts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'answered_by': answeredBy,
      'role': role,
      'timestamp': timestamp,
    };
  }

  Answer copyWith({
    String? content,
    String? answeredBy,
    String? role,
    int? timestamp,
  }) {
    return Answer(
      content: content ?? this.content,
      answeredBy: answeredBy ?? this.answeredBy,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
