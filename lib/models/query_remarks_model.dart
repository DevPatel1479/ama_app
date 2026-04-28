class QueryRemarksResponse {
  final bool success;
  final String message;
  final Data? data;

  QueryRemarksResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory QueryRemarksResponse.fromJson(Map<String, dynamic> json) {
    return QueryRemarksResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    );
  }
}

class Data {
  final String queryId;
  final String parentDocId;
  final String remarks;

  Data({
    required this.queryId,
    required this.parentDocId,
    required this.remarks,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      queryId: json["queryId"] ?? "",
      parentDocId: json["parentDocId"] ?? "",
      remarks: json["remarks"] ?? "",
    );
  }
}
