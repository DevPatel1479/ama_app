// models/check_service_type_response_model.dart

class CheckServiceTypeResponseModel {
  final bool success;
  final String message;
  final bool isLoanSettlement;
  final String serviceType;

  CheckServiceTypeResponseModel({
    required this.success,
    required this.message,
    required this.isLoanSettlement,
    required this.serviceType,
  });

  factory CheckServiceTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckServiceTypeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isLoanSettlement: json['isLoanSettlement'] ?? false,
      serviceType: json['serviceType'] ?? '',
    );
  }
}
