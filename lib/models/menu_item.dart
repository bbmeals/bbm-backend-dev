class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final int calories;
  final String category;
  final bool availability;
  final DateTime lastUpdated;
  final String imageUrl;
  final Map<String, String> ingredients;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.category,
    required this.availability,
    required this.lastUpdated,
    required this.imageUrl,
    required this.ingredients,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    restaurantId: json['restaurantId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    calories: json['calories'] as int,
    category: json['category'] as String,
    availability: json['availability'] as bool,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    imageUrl: json['imageUrl'] as String,
    ingredients: Map<String, String>.from(json['ingredients']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'name': name,
    'description': description,
    'price': price,
    'calories': calories,
    'category': category,
    'availability': availability,
    'lastUpdated': lastUpdated.toIso8601String(),
    'imageUrl': imageUrl,
    'ingredients': ingredients,
  };
}
