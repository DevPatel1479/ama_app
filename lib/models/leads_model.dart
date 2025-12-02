import 'package:ama_legal_solutions/models/leads_user_model.dart';

class LeadsResponseModel {
  final bool success;
  final String message;
  final LeadUserModel? data; // typed model instead of dynamic

  LeadsResponseModel({required this.success, required this.message, this.data});

  factory LeadsResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadsResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null && json["data"] is Map<String, dynamic>
          ? LeadUserModel.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"success": success, "message": message, "data": data?.toJson()};
  }
}
