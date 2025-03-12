import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';

Router orderRoutes() {
  final router = Router();

  // GET /orders - Get all orders
  router.get('/', (Request request) async {
    try {
      final orders = await FirebaseService.getCollection("orders");
      return Response.ok(jsonEncode(orders), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // GET /orders/<orderId> - Get a specific order
  router.get('/<orderId>', (Request request, String orderId) async {
    try {
      final order = await FirebaseService.getDocument("orders", orderId);

      if (order == null) {
        return Response.notFound(jsonEncode({'error': 'Order not found'}));
      }

      return Response.ok(jsonEncode(order), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // POST /orders/<userId>/place - Place an order and clear the user's cart subcollection
  router.post('/<userId>/place', (Request request, String userId) async {
    try {
      final rawPayload = await request.readAsString();
      final payload = jsonDecode(rawPayload) as Map<String, dynamic>;

      // Add the userId to the payload.
      payload['userId'] = {"stringValue": userId};

      // Set timestamps if not provided.
      final now = DateTime.now().toUtc().toIso8601String();
      payload.putIfAbsent('created_at', () => now);
      payload.putIfAbsent('updated_at', () => now);

      // Validate required fields.
      if (!payload.containsKey('items')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing items field'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (!payload.containsKey('delivery_type')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing delivery_type field'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (!payload.containsKey('delivery_address')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing delivery_address field'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (!payload.containsKey('total')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing total field'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Create the order by saving it to the "orders" collection.
      final orderId = await FirebaseService.addDocument("orders", payload);
      payload['id'] = orderId;

      // Clear the user's cart subcollection using getCollection and deleteDocument.
      final cartDocuments = await FirebaseService.getCollection("users/$userId/cart");
      for (final doc in cartDocuments) {
        await FirebaseService.deleteDocument("users/$userId/cart", doc['id']);
      }

      return Response.ok(
        jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print("Error placing order: $e");
      print("Stack trace: $stackTrace");
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Internal Server Error',
          'details': e.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });




  return router;
}
