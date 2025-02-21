import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'routes/menu_routes.dart';
import 'routes/cart_routes.dart';
import 'routes/subscription_routes.dart';
import 'routes/order_routes.dart';

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
  try {
    // Create the main router and mount sub-routers.
    final router = Router();

    // Add a test endpoint
    router.get('/test', (Request request) {
      return Response.ok('Server is running!');
    });

    // Mount routes
    router.mount('/restaurants', menuRoutes());
    router.mount('/users', cartRoutes());
    router.mount('/users', subscriptionRoutes());
    router.mount('/orders', orderRoutes());

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsMiddleware())
        .addHandler(router);

    // Determine port (default to 8080)
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final server = await io.serve(handler, '0.0.0.0', port);
    print('✅ Server running on port ${server.port}');
  } catch (e) {
    print('❌ Server error: $e');
    exit(1);
  }
}