// lib/models/notification_model.dart

class NotificationHistoryModel {
  final String id;
  final String title;
  final String body;
  final int timestamp;
  final String? sentBy;
  final List<dynamic> topics;

  NotificationHistoryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.sentBy,
    this.topics = const [],
  });

  factory NotificationHistoryModel.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryModel(
      id: json['id'] ?? '',
      title: json['n_title'] ?? '',
      body: json['n_body'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      sentBy: json['sent_by'],
      topics: List<dynamic>.from(json['topics'] ?? []),
    );
  }
}
