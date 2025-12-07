class RemarkItem {
  final int index;
  final String remarks;
  final int createdAt;

  RemarkItem({
    required this.index,
    required this.remarks,
    required this.createdAt,
  });

  factory RemarkItem.fromJson(Map<String, dynamic> json) {
    return RemarkItem(
      index: int.tryParse(json['index'].toString()) ?? 0,
      remarks: json['remarks'] ?? "",
      createdAt: json['createdAt'] ?? 0,
    );
  }
}

class RemarkResponse {
  final bool success;
  final String message;
  final List<RemarkItem> data;

  RemarkResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RemarkResponse.fromJson(Map<String, dynamic> json) {
    return RemarkResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => RemarkItem.fromJson(e))
          .toList(),
    );
  }
}
