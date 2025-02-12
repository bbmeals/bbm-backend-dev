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

  return router;
}
