class CartItem {
  // final String id;
  final String userId;
  final String restaurantId;
  final String itemId;
  final int quantity;
  final double priceSnapshot;
  final Map<String, String> customization;
  final DateTime createdAt;

  CartItem({
    // required this.id,
    required this.userId,
    required this.restaurantId,
    required this.itemId,
    required this.quantity,
    required this.priceSnapshot,
    required this.customization,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    // id: json['id'] as String,
    userId: json['userId'] as String,
    restaurantId: json['restaurantId'] as String,
    itemId: json['itemId'] as String,
    quantity: json['quantity'] as int,
    priceSnapshot: (json['priceSnapshot'] as num).toDouble(),
    customization: Map<String, String>.from(json['customization']),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    // 'id': id,
    'userId': userId,
    'restaurantId': restaurantId,
    'itemId': itemId,
    'quantity': quantity,
    'priceSnapshot': priceSnapshot,
    'customization': customization,
    'createdAt': createdAt.toIso8601String(),
  };
}
