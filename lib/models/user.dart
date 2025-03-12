class User {
  final String? id;
  final String? name;
  final String? email;
  final String phone;
  final DateTime? createdAt;

  User({
    this.id,
    this.name,
    this.email,
    required this.phone,
    DateTime? createdAt,
  }): createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = {'stringValue': id};
    if (name != null) data['name'] = {'stringValue': name};
    if (email != null) data['email'] = {'stringValue': email};
    data['phone'] = {'stringValue': phone};
    if (createdAt != null) {
      // Ensure the timestamp is in UTC ISO8601 format with a trailing "Z"
      data['createdAt'] = {'timestampValue': createdAt!.toUtc().toIso8601String()};
    }
    return data;
  }

}
