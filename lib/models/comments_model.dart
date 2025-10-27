// models/comment_model.dart
class Comment {
  final String id;
  final String commentedBy;
  final String? userRole;
  final String? phone;
  final String? profileImgUrl;
  final String content;
  final int? commentsCount;
  final int timestamp;

  Comment({
    required this.id,
    required this.commentedBy,
    this.userRole,
    this.commentsCount,
    this.phone,
    this.profileImgUrl,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      commentedBy: map['commentedBy'] as String,
      userRole: map['userRole'] as String?,
      phone: map['phone'] as String?,
      commentsCount: map["commentsCount"] as int?,
      profileImgUrl: map['profileImgUrl'] as String?,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commentedBy': commentedBy,
      'userRole': userRole,
      'phone': phone,
      'profileImgUrl': profileImgUrl,
      'content': content,
      'commentsCount': commentsCount,
      'timestamp': timestamp,
    };
  }
}
