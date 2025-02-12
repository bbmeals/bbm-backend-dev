import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';

Router cartRoutes() {
  final router = Router();

  // GET /users/<userId>/cart - Get all cart items for a user
  router.get('/<userId>/cart', (Request request, String userId) async {
    try {
      final cartItems = await FirebaseService.getCollection("users/$userId/cart");
      return Response.ok(jsonEncode(cartItems), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // GET /users/<userId>/cart/<cartItemId> - Get a specific cart item
  router.get('/<userId>/cart/<cartItemId>', (Request request, String userId, String cartItemId) async {
    try {
      final cartItem = await FirebaseService.getDocument("users/$userId/cart", cartItemId);

      if (cartItem == null) {
        return Response.notFound(jsonEncode({'error': 'Cart item not found'}));
      }

      return Response.ok(jsonEncode(cartItem), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
