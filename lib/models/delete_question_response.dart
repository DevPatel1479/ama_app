class DeleteQuestionResponse {
  final bool success;
  final String message;
  final String? questionId;

  DeleteQuestionResponse({
    required this.success,
    required this.message,
    this.questionId,
  });

  factory DeleteQuestionResponse.fromJson(Map<String, dynamic> json) {
    return DeleteQuestionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      questionId: json['questionId'],
    );
  }
}
