import 'package:intl/intl.dart' show DateFormat;

DateTime? _parseFirestoreTimestamp(dynamic value) {
  if (value == null) return null;

  try {
    // 1️⃣ Firestore Timestamp map
    if (value is Map && value.containsKey('_seconds')) {
      final int seconds = (value['_seconds'] as num).toInt();
      final int nanos = ((value['_nanoseconds'] as num?) ?? 0).toInt();

      final int millis = seconds * 1000 + (nanos ~/ 1000000);

      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
    }

    // 2️⃣ Milliseconds since epoch
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
    }

    // 3️⃣ ISO 8601 string
    if (value is String) {
      final iso = DateTime.tryParse(value);
      if (iso != null) return iso.toLocal();

      // 4️⃣ Human readable backend format
      // "August 1, 2025 at 4:16:38 AM UTC+5:30"
      return DateFormat(
        "MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z",
      ).parse(value, true).toLocal();
    }
  } catch (e) {
    // debugPrint("❌ Failed to parse timestamp: $value | $e");
  }

  return null;
}

class BillcutLead {
  final String id;
  final String? address;
  final String? assignedToId;
  final String? assignedTo;
  final String? category;
  final int? date; // stored as number (ms)
  final String? debtRange;
  final String? email;
  final String? income;
  final String? mobile;
  final String? name;
  final String? salesNotes;
  final DateTime? lastModified;
  final DateTime? syncedDate;

  BillcutLead({
    required this.id,
    this.address,
    this.assignedToId,
    this.assignedTo,
    this.category,
    this.date,
    this.debtRange,
    this.email,
    this.income,
    this.mobile,
    this.name,
    this.salesNotes,
    this.lastModified,
    this.syncedDate,
  });

  factory BillcutLead.fromFirestore(Map<String, dynamic> json) {
    return BillcutLead(
      id: json['id'] ?? '',
      address: json['address'] as String?,
      assignedToId: json['assignedToId'] as String?,
      assignedTo: json['assigned_to'] as String?,
      category: json['category'] as String?,
      date: (json['date'] as num?)?.toInt(),
      debtRange: json['debt_range'] as String?,
      email: json['email'] as String?,
      income: json['income'] as String?,
      mobile: json['mobile'] as String?,
      name: json['name'] as String?,
      salesNotes: json['sales_notes'] as String?,
      lastModified: _parseFirestoreTimestamp(json['lastModified']),
      syncedDate: _parseFirestoreTimestamp(json['synced_date']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'address': address,
      'assignedToId': assignedToId,
      'assigned_to': assignedTo,
      'category': category,
      'date': date,
      'debt_range': debtRange,
      'email': email,
      'income': income,
      'mobile': mobile,
      'name': name,
      'sales_notes': salesNotes,
      'lastModified': lastModified,
      'synced_date': syncedDate,
    };
  }
}
