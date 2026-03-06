import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final int timestamp;
  final String? sentBy;
  final List<String>? topics;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.sentBy,
    this.topics,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      sentBy: map['sent_by'],
      topics: map['topics'] != null
          ? List<String>.from(map['topics'])
          : <String>[],
    );
  }

  static List<NotificationModel> fromJsonList(String jsonStr) {
    final data = json.decode(jsonStr);
    if (data['data'] == null) return [];
    return List<NotificationModel>.from(
      data['data'].map((item) => NotificationModel.fromMap(item)),
    );
  }
}
