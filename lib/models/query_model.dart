import 'package:cloud_firestore/cloud_firestore.dart';

class ResolvedBy {
  final String role;
  final String? phone;
  final String? name;

  ResolvedBy({required this.role, this.phone, this.name});

  // Always return non-null string for required fields, nullable for optional
  static String _toNonNullString(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static String? _toNullableString(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  factory ResolvedBy.fromJson(Map<String, dynamic> json) {
    return ResolvedBy(
      role: _toNonNullString(json['role']),
      phone: _toNullableString(json['phone']),
      name: _toNullableString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'role': role};
    if (phone != null) map['phone'] = phone;
    if (name != null) map['name'] = name;
    return map;
  }
}

class QueryModel {
  final String id; // queryId/doc id as string
  final String query;
  final int submittedAt; // unix seconds (non-null)
  final String postedBy;
  final String status;
  final String? role;
  final String? phone;
  final String? parentDocId;
  final String? path;
  final int? resolvedAt;
  final ResolvedBy? resolvedBy;
  final String? remarks;

  QueryModel({
    required this.id,
    required this.query,
    required this.submittedAt,
    required this.status,
    required this.postedBy,
    this.role,
    this.phone,
    this.parentDocId,
    this.path,
    this.resolvedAt,
    this.resolvedBy,
    this.remarks,
  });

  // Helpers for safe conversion
  static String _toNonNullString(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static String? _toNullableString(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  static int? _nullableIntFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    if (v is Timestamp) return v.seconds;
    // fallback try parse
    return int.tryParse(v.toString());
  }

  static int _intFromDefaultZero(dynamic v) {
    return _nullableIntFrom(v) ?? 0;
  }

  /// Defensive factory that will never assign an int directly to a String.
  factory QueryModel.fromJson(Map<String, dynamic> json) {
    try {
      final Map<String, dynamic> m = Map<String, dynamic>.from(json);

      // id: prefer queryId then id; always string
      final String idVal = _toNonNullString(m['queryId'] ?? m['id'] ?? '');

      // path
      final String? pathVal = _toNullableString(m['path']);

      // query text
      final String queryText = _toNonNullString(m['query'] ?? '');

      // submitted_at: convert timestamp/int/string -> int seconds
      final int submittedAtVal = _intFromDefaultZero(
        m['submitted_at'] ?? m['submittedAt'],
      );

      // status
      final String statusVal = _toNonNullString(m['status']).isEmpty
          ? 'pending'
          : _toNonNullString(m['status']);

      // optional fields as strings
      final String? roleVal = m.containsKey('role')
          ? _toNullableString(m['role'])
          : null;
      final String? phoneVal = m.containsKey('phone')
          ? _toNullableString(m['phone'])
          : null;
      final String? parentDocIdVal = m.containsKey('parentDocId')
          ? _toNullableString(m['parentDocId'])
          : (m.containsKey('parent_doc_id')
                ? _toNullableString(m['parent_doc_id'])
                : null);

      final int? resolvedAtVal = _nullableIntFrom(
        m['resolved_at'] ?? m['resolvedAt'],
      );

      final ResolvedBy? resolvedByVal = m['resolved_by'] != null
          ? ResolvedBy.fromJson(Map<String, dynamic>.from(m['resolved_by']))
          : null;

      final String? remarksVal = m.containsKey('remarks')
          ? _toNullableString(m['remarks'])
          : null;

      return QueryModel(
        id: idVal,
        query: queryText,
        submittedAt: submittedAtVal,
        status: statusVal,
        role: roleVal,
        phone: phoneVal,
        parentDocId: parentDocIdVal,
        path: pathVal,
        resolvedAt: resolvedAtVal,
        resolvedBy: resolvedByVal,
        remarks: remarksVal,
        postedBy: json["posted_by"],
      );
    } catch (e, st) {
      // If a parsing bug still happens, log the raw payload to help debugging
      // (You can remove these prints in production)
      print("QueryModel.fromJson PARSE ERROR: $e");
      print("Raw JSON: $json");
      print(st);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'queryId': id,
      'query': query,
      'submitted_at': submittedAt,
      'status': status,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (parentDocId != null) 'parentDocId': parentDocId,
      if (path != null) 'path': path,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolvedBy != null) 'resolved_by': resolvedBy!.toJson(),
      if (remarks != null) 'remarks': remarks,
    };
    return map;
  }
}
