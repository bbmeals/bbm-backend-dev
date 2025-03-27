import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';
import '../models/cart_item.dart';
import '../models/user.dart';

Router cartRoutes() {
  final router = Router();

  router.get('/<userId>/cart', (Request request, String userId) async {
    try {
      print('Fetching all cart items for user: $userId');

      // Retrieve all cart documents, defaulting to an empty list if null.
      final dynamic rawCartDocuments = await FirebaseService.getCollection("users/$userId/cart");
      final List<dynamic> cartDocuments = rawCartDocuments is List<dynamic> ? rawCartDocuments : [];

      List combinedCartData = [];

      for (var cartDoc in cartDocuments) {
        // Directly access the values since they are already decoded into plain Dart types
        final restaurantId = cartDoc['restaurantId'];
        final itemId = cartDoc['itemId'];

        // Fetch menu item details.
        final menuDoc = await FirebaseService.getDocument("restaurants/$restaurantId/menu", itemId);

        if (menuDoc != null) {
          cartDoc['menuDetails'] = menuDoc;
        }

        combinedCartData.add(cartDoc);
      }

      return Response.ok(
        jsonEncode(combinedCartData),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching combined cart items: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
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

  router.post('/<userId>/cart', (Request request, String userId) async {
    try {
      print('Function called');

      // Read and decode the incoming payload
      final rawPayload = await request.readAsString();
      final payload = jsonDecode(rawPayload) as Map<String, dynamic>;
      payload['userId'] = userId;


      // Set createdAt to the current UTC time if it's not provided
      if (!payload.containsKey('createdAt')) {
        payload['createdAt'] = DateTime.now().toUtc().toIso8601String();
      }
      print('createdAt: ${payload['createdAt']}');

      // Validate payload structure using the CartItem model with a dummy id
      final validationPayload = Map<String, dynamic>.from(payload);
      validationPayload['id'] = 'temp';
      CartItem.fromJson(validationPayload);

      // Create a CartItem instance (id is a placeholder)
      final cartItem = CartItem(
        // id: '', // Firestore will generate a new id
        userId: payload['userId'],
        restaurantId: payload['restaurantId'],
        itemId: payload['itemId'],
        quantity: payload['quantity'],
        priceSnapshot: payload['priceSnapshot'],
        customization: Map<String, String>.from(payload['customization']),
        createdAt: DateTime.parse(payload['createdAt']),
      );

      // Pass the plain Dart map so that addDocument can perform the proper conversion.
      final cartItemData = cartItem.toJson();

      // Add the document to Firestore using the correctly formatted JSON
      final newId = await FirebaseService.addDocument("users/$userId/cart", cartItemData);
      payload['id'] = newId;

      return Response.ok(
        jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });


  // To update cart item quantity or remove item if quantity is 0
  router.put('/<userId>/cart/<cartItemId>', (Request request, String userId, String cartItemId) async {
    try {
      print('Update cart quantity route called');

      // Read and decode the incoming payload
      final rawPayload = await request.readAsString();
      final payload = jsonDecode(rawPayload) as Map<String, dynamic>;

      // Ensure that the payload contains the 'quantity' field
      if (!payload.containsKey('quantity')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing quantity field'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Extract quantity value
      final quantity = payload['quantity'];

      // If quantity is 0, remove the item instead of updating
      if (quantity == null || quantity == 0) {
        print('Removing item: $cartItemId');
        await FirebaseService.deleteDocument("users/$userId/cart", cartItemId);
        return Response.ok(
          jsonEncode({'message': 'Cart item removed successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Normal update if quantity > 0
      print('Updating cart item quantity for $cartItemId to $quantity');
      final updateData = {
        'quantity': quantity,
      };

      await FirebaseService.updateDocument("users/$userId/cart", cartItemId, updateData);
      payload['id'] = cartItemId;
      return Response.ok(
        jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
