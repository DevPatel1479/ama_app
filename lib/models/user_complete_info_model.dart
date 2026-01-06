class UserCompleteInfoModel {
  final String email;
  final List<DocumentModel> documents;
  final String monthlyFees;
  final String leadId;
  final List<BankModel> banks;
  final String tenure;
  final String dob;
  final String phone;
  final String name;
  final String city;
  final String panNumber;
  final String aadharNumber;
  final String occupation;
  final String status;

  // Extra fields from API
  final String? allocAdv;
  final Map<String, dynamic>? allocAdvAt;
  final String? allocAdvSecondary;
  final Map<String, dynamic>? allocAdvSecondaryAt;
  final String? monthlyIncome;
  final String? advocatePhoneNumber;
  final String? personalLoanDues;
  final String? assignedTo;
  final String? startDate;
  final String? advStatus;
  final String? creditCardDues;
  final String? sourceDatabase;
  final bool? requestLetter;
  final bool? convertedFromLead;
  final bool? sentAgreement;
  final Map<String, dynamic>? lastUpdated;
  final Map<String, dynamic>? convertedAt;
  final Map<String, dynamic>? lastModified;
  final String? remarks;

  UserCompleteInfoModel({
    required this.email,
    required this.documents,
    required this.monthlyFees,
    required this.leadId,
    required this.banks,
    required this.tenure,
    required this.dob,
    required this.phone,
    required this.name,
    required this.city,
    required this.panNumber,
    required this.aadharNumber,
    required this.occupation,
    required this.status,
    this.allocAdv,
    this.allocAdvAt,
    this.allocAdvSecondary,
    this.allocAdvSecondaryAt,
    this.monthlyIncome,
    this.advocatePhoneNumber,
    this.personalLoanDues,
    this.assignedTo,
    this.startDate,
    this.advStatus,
    this.creditCardDues,
    this.sourceDatabase,
    this.requestLetter,
    this.convertedFromLead,
    this.sentAgreement,
    this.lastUpdated,
    this.convertedAt,
    this.lastModified,
    this.remarks,
  });

  factory UserCompleteInfoModel.fromJson(Map<String, dynamic> json) {
    return UserCompleteInfoModel(
      email: json["email"] ?? "",
      documents:
          (json["documents"] as List<dynamic>?)
              ?.map((doc) => DocumentModel.fromJson(doc))
              .toList() ??
          [],
      monthlyFees: json["monthlyFees"] ?? "",
      leadId: json["leadId"] ?? "",
      banks:
          (json["banks"] as List<dynamic>?)
              ?.map((bank) => BankModel.fromJson(bank))
              .toList() ??
          [],
      tenure: json["tenure"] ?? "",
      dob: json["dob"] ?? "",
      phone: json["phone"] ?? "",
      name: json["name"] ?? "",
      city: json["city"] ?? "",
      panNumber: json["panNumber"] ?? "",
      aadharNumber: json["aadharNumber"] ?? "",
      occupation: json["occupation"] ?? "",
      status: json["status"] ?? "",

      // Extra fields
      allocAdv: json["alloc_adv"],
      allocAdvAt: json["alloc_adv_at"],
      allocAdvSecondary: json["alloc_adv_secondary"],
      allocAdvSecondaryAt: json["alloc_adv_secondary_at"],
      monthlyIncome: json["monthlyIncome"],
      advocatePhoneNumber: json["advocate_phonenumber"],
      personalLoanDues: json["personalLoanDues"],
      assignedTo: json["assignedTo"],
      startDate: json["startDate"],
      advStatus: json["adv_status"],
      creditCardDues: json["creditCardDues"],
      sourceDatabase: json["source_database"],
      requestLetter: json["request_letter"],
      convertedFromLead: json["convertedFromLead"],
      sentAgreement: json["sentAgreement"],
      lastUpdated: json["lastUpdated"],
      convertedAt: json["convertedAt"],
      lastModified: json["lastModified"],
      remarks: json["remarks"],
    );
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final v = value.toLowerCase().trim();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return false;
}

/// Bank Model
class BankModel {
  final String bankName;
  final String loanAmount;
  final String id;
  final String accountNumber;
  final String loanType;
  final bool settled;
  BankModel({
    required this.bankName,
    required this.loanAmount,
    required this.id,
    required this.accountNumber,
    required this.loanType,
    required this.settled,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      bankName: json["bankName"] ?? "",
      loanAmount: json["loanAmount"] ?? "",
      id: json["id"] ?? "",
      accountNumber: json["accountNumber"] ?? "",
      loanType: json["loanType"] ?? "",
      settled: _parseBool(json["settled"]),
    );
  }
}

/// Document Model
class DocumentModel {
  final String name;
  final String htmlUrl;
  final String accountType;
  final String bankName;
  final String createdAt;
  final String url;
  final String type;

  DocumentModel({
    required this.name,
    required this.htmlUrl,
    required this.accountType,
    required this.bankName,
    required this.createdAt,
    required this.url,
    required this.type,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json["name"] ?? "",
      htmlUrl: json["htmlUrl"] ?? "",
      accountType: json["accountType"] ?? "",
      bankName: json["bankName"] ?? "",
      createdAt: json["createdAt"] ?? "",
      url: json["url"] ?? "",
      type: json["type"] ?? "",
    );
  }
}
