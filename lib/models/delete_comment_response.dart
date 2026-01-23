class DeleteCommentResponse {
  final bool success;
  final String message;
  final String? commentId;

  DeleteCommentResponse({
    required this.success,
    required this.message,
    this.commentId,
  });

  factory DeleteCommentResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCommentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      commentId: json['commentId'],
    );
  }
}
