DateTime? _parseFirestoreTimestamp(dynamic value) {
  if (value == null) return null;

  // Firestore Timestamp map
  if (value is Map && value.containsKey('_seconds')) {
    final seconds = value['_seconds'];
    final nanos = value['_nanoseconds'] ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000 + (nanos / 1000000).round(),
      isUtc: true,
    ).toLocal();
  }

  // Already ISO string fallback
  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

class AmaLeadModel {
  final String id;
  final String address;
  final String assignedTo;
  final String assignedToId;
  final String assignedToRaw; // assigned_to
  final int date;
  final int debtRange;
  final String email;
  final int income;
  final DateTime? lastModified;
  final int mobile;
  final String name;
  final String originalCollection;
  final String originalId;
  final String query;
  final String source;
  final String sourceDatabase;
  final String status;
  final DateTime? syncedAt;
  final int syncedDate;

  AmaLeadModel({
    required this.id,
    required this.address,
    required this.assignedTo,
    required this.assignedToId,
    required this.assignedToRaw,
    required this.date,
    required this.debtRange,
    required this.email,
    required this.income,
    required this.lastModified,
    required this.mobile,
    required this.name,
    required this.originalCollection,
    required this.originalId,
    required this.query,
    required this.source,
    required this.sourceDatabase,
    required this.status,
    required this.syncedAt,
    required this.syncedDate,
  });

  factory AmaLeadModel.fromJson(Map<String, dynamic> json) {
    return AmaLeadModel(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      assignedTo: json['assignedTo'] ?? json['assigned_to'] ?? '',
      assignedToId: json['assignedToId'] ?? json['assigned_to_id'] ?? '',
      assignedToRaw: json['assigned_to'] ?? '',
      date: json['date'] ?? 0,
      debtRange: json['debt_range'] ?? 0,
      email: json['email'] ?? '',
      income: json['income'] ?? 0,

      lastModified: _parseFirestoreTimestamp(json['lastModified']),
      syncedAt: _parseFirestoreTimestamp(json['synced_at']),

      mobile: int.tryParse(json['mobile']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      originalCollection: json['original_collection'] ?? '',
      originalId: json['original_id'] ?? '',
      query: json['query'] ?? '',
      source: json['source'] ?? '',
      sourceDatabase: json['source_database'] ?? '',
      status: json['status'] ?? '',
      syncedDate: json['synced_date'] ?? 0,
    );
  }
}
