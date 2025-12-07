class TeamMember {
  final String id;
  final String name;
  final String position;
  final String image;

  TeamMember({
    required this.id,
    required this.name,
    required this.position,
    required this.image,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class TeamResponse {
  final bool success;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<TeamMember> data;

  TeamResponse({
    required this.success,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  factory TeamResponse.fromJson(Map<String, dynamic> json) {
    return TeamResponse(
      success: json['success'] ?? false,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TeamMember.fromJson(e))
              .toList() ??
          [],
    );
  }
}
