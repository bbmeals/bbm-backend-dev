class Restaurant {
  final String id;
  final String name;
  final String address;
  final String cuisine;
  final double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.cuisine,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    cuisine: json['cuisine'] as String,
    rating: (json['rating'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'cuisine': cuisine,
    'rating': rating,
  };
}
