class Address {
  final String? apt; // Optional apartment/unit
  final String street;
  final String city;
  final String pin; // Postal code
  final String type; // e.g., "home", "office"

  Address({
    this.apt,
    required this.street,
    required this.city,
    required this.pin,
    required this.type,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      apt: json['apt'] as String?,
      street: json['street'] as String,
      city: json['city'] as String,
      pin: json['pin'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apt': apt,
      'street': street,
      'city': city,
      'pin': pin,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Address(apt: $apt, street: $street, city: $city, pin: $pin, type: $type)';
  }
}
