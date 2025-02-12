import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';

Router menuRoutes() {
  final router = Router();

  // GET /restaurants/ - Fetch all restaurants
  router.get('/', (Request request) async {
    try {
      final restaurants = await FirebaseService.getCollection("restaurants");
      return Response.ok(jsonEncode(restaurants), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // GET /restaurants/<restaurantId> - Fetch a specific restaurant
  router.get('/<restaurantId>', (Request request, String restaurantId) async {
    try {
      final restaurant = await FirebaseService.getDocument("restaurants", restaurantId);

      if (restaurant == null) {
        return Response.notFound(jsonEncode({'error': 'Restaurant not found'}));
      }

      return Response.ok(jsonEncode(restaurant), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  // POST /restaurants/ - Add a new restaurant
  router.post('/', (Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      await FirebaseService.addDocument("restaurants", payload);
      return Response.ok(jsonEncode({'message': 'Restaurant added successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  });

  return router;
}
