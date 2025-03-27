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
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
    } catch (e) {
      print('Error parsing User from JSON: $e');
      throw Exception('Error parsing User from JSON: $e');
    }
  }


  Map<String, dynamic> toJson() {
    try {
      final data = <String, dynamic>{};
      if (id != null) data['id'] = id;
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      data['phone'] = phone;
      if (createdAt != null) {
        // Convert the DateTime to a UTC ISO8601 formatted string.
        data['createdAt'] = createdAt!.toUtc().toIso8601String();
      }
      return data;
    } catch (e) {
      print('Error converting User to JSON: $e');
      throw Exception('Error converting User to JSON: $e');
    }
  }

}
