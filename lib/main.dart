import 'dart:io';
import 'package:bbm_backend_dev/services/firebase_service.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'routes/menu_routes.dart';
import 'routes/cart_routes.dart';
import 'routes/subscription_routes.dart';
import 'routes/order_routes.dart';

/// Your Firebase project ID & API Key
const String projectId = "bbm-db-dev"; // 🔥 Replace with your Firebase Project ID
const String apiKey = "AIzaSyCfU0FvHfoG0uvCcETG6pWr8xUZtNSBix0"; // 🔥 Replace with your Firebase Web API Key


/// A simple CORS middleware.
Middleware corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('',
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, DELETE, PATCH, OPTIONS',
              'Access-Control-Allow-Headers': 'Origin, Content-Type'
            });
      }
      return null;
    },
    responseHandler: (Response response) =>
        response.change(headers: {'Access-Control-Allow-Origin': '*'}),
  );
}

Future<void> main(List<String> args) async {
  // Create the main router and mount sub-routers.
  final router = Router();

  // Mount routes.
  router.mount('/restaurants/', menuRoutes());
  router.mount('/users/', cartRoutes()); // Handles /users/<userId>/cart
  router.mount('/users/', subscriptionRoutes()); // Handles /users/<userId>/subscriptions
  router.mount('/orders/', orderRoutes());
  // router.mount('/user/', orderRoutes());

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router);

  // Determine port (default to 8080)
  final port = int.parse(Platform.environment['PORT'] ?? '8087');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('✅ Server running on port ${server.port}');
}
