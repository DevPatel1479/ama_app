class LeadUserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? state;

  LeadUserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.state,
  });

  factory LeadUserModel.fromJson(Map<String, dynamic> json) {
    return LeadUserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "state": state,
    };
  }

  LeadUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? state,
  }) {
    return LeadUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      state: state ?? this.state,
    );
  }
}
