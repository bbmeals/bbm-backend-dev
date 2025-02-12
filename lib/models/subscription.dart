class Subscription {
  final String id;
  final String userId;
  final String restaurantId;
  final Map<String, dynamic> schedule;
  final List<String> mealPlan;
  final String status;
  final DateTime nextDelivery;
  final String paymentMethodId;
  final DateTime startDate;
  final DateTime? endDate;

  Subscription({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.schedule,
    required this.mealPlan,
    required this.status,
    required this.nextDelivery,
    required this.paymentMethodId,
    required this.startDate,
    this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] as String,
    userId: json['userId'] as String,
    restaurantId: json['restaurantId'] as String,
    schedule: json['schedule'] as Map<String, dynamic>,
    mealPlan: List<String>.from(json['mealPlan'] as List),
    status: json['status'] as String,
    nextDelivery: DateTime.parse(json['nextDelivery'] as String),
    paymentMethodId: json['paymentMethodId'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'restaurantId': restaurantId,
    'schedule': schedule,
    'mealPlan': mealPlan,
    'status': status,
    'nextDelivery': nextDelivery.toIso8601String(),
    'paymentMethodId': paymentMethodId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
  };
}
