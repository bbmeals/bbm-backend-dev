import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';

Router subscriptionRoutes() {
  final router = Router();

  // GET /users/<userId>/subscriptions - Get all subscriptions for a user
  router.get('/<userId>/subscriptions', (Request request, String userId) async {
    try {
      final subscriptions = await FirebaseService.getCollection("users/$userId/subscriptions");
      return Response.ok(jsonEncode(subscriptions), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // GET /users/<userId>/subscriptions/<subscriptionId> - Get a specific subscription
  router.get('/<userId>/subscriptions/<subscriptionId>', (Request request, String userId, String subscriptionId) async {
    try {
      final subscription = await FirebaseService.getDocument("users/$userId/subscriptions", subscriptionId);

      if (subscription == null) {
        return Response.notFound(jsonEncode({'error': 'Subscription not found'}));
      }

      return Response.ok(jsonEncode(subscription), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
