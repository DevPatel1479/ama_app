class ResolveQueryModel {
  final bool success;
  final String message;
  final ResolveQueryData? data;

  ResolveQueryModel({required this.success, required this.message, this.data});

  factory ResolveQueryModel.fromJson(Map<String, dynamic> json) {
    return ResolveQueryModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ResolveQueryData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class ResolveQueryData {
  final String queryId;
  final String? parentDocId;
  final String status;
  final int resolvedAt;
  final ResolvedBy resolvedBy;
  final String? remarks;

  ResolveQueryData({
    required this.queryId,
    this.parentDocId,
    required this.status,
    required this.resolvedAt,
    required this.resolvedBy,
    this.remarks,
  });

  factory ResolveQueryData.fromJson(Map<String, dynamic> json) {
    return ResolveQueryData(
      queryId: json['queryId'] ?? '',
      parentDocId: json['parentDocId'],
      status: json['status'] ?? 'pending',
      resolvedAt: json['resolved_at'] ?? 0,
      resolvedBy: ResolvedBy.fromJson(
        Map<String, dynamic>.from(json['resolved_by']),
      ),
      remarks: json['remarks'],
    );
  }
}

class ResolvedBy {
  final String role;
  final String? phone;
  final String? name;

  ResolvedBy({required this.role, this.phone, this.name});

  factory ResolvedBy.fromJson(Map<String, dynamic> json) {
    return ResolvedBy(
      role: json['role'] ?? '',
      phone: json['phone'],
      name: json['name'],
    );
  }
}
