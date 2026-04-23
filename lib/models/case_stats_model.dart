class CaseStatsModel {
  final String caseHandled;
  final String clientServed;
  final String yrExp;

  CaseStatsModel({
    required this.caseHandled,
    required this.clientServed,
    required this.yrExp,
  });

  factory CaseStatsModel.fromMap(Map<String, dynamic> map) {
    return CaseStatsModel(
      caseHandled: map['case_handled'] ?? "10",
      clientServed: map['client_served'] ?? "40",
      yrExp: map['yr_exp'] ?? "5",
    );
  }
}
