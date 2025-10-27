import 'dart:convert';

class AnswerModel {
  final String content;
  final String answeredBy;
  final String role;
  final int timestamp;

  AnswerModel({
    required this.content,
    required this.answeredBy,
    required this.role,
    required this.timestamp,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      content: json['content'] ?? '',
      answeredBy: json['answered_by'] ?? '',
      role: json['role'] ?? '',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "content": content,
    "answered_by": answeredBy,
    "role": role,
    "timestamp": timestamp,
  };

  static AnswerModel fromJsonString(String jsonString) {
    final jsonData = jsonDecode(jsonString);
    return AnswerModel.fromJson(jsonData);
  }
}
