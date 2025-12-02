class UpdateUserResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? updated;

  UpdateUserResponse({
    required this.success,
    required this.message,
    this.updated,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      updated: json['updated'] != null
          ? Map<String, dynamic>.from(json['updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'updated': updated};
  }
}
