import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTestService {
  final String baseUrl;

  ApiTestService({this.baseUrl = 'http://localhost:8080'});

  Future<void> testRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants/'));
    if (response.statusCode == 200) {
      print("Restaurants: ${jsonDecode(response.body)}");
    } else {
      print("Error fetching restaurants: ${response.statusCode}");
    }
  }

  Future<void> testRestaurant(String restaurantId) async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants/$restaurantId'));
    if (response.statusCode == 200) {
      print("Restaurant $restaurantId: ${jsonDecode(response.body)}");
    } else {
      print("Error fetching restaurant $restaurantId: ${response.statusCode}");
    }
  }

// Add additional test methods for cart, subscriptions, orders, etc.
}
