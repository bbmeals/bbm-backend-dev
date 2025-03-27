import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';

Router menuRoutes() {
  final router = Router();

  // GET /restaurants/ - Fetch all restaurants
  router.get('/', (Request request) async {
    try {
      // getCollection returns plain Dart types
      final restaurants = await FirebaseService.getCollection("restaurants");
      return Response.ok(
        jsonEncode(restaurants),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });

  // POST /restaurants/ - Add a new restaurant
  router.post('/', (Request request) async {
    try {
      // Read and decode the incoming payload as a plain Dart map.
      final payload = jsonDecode(await request.readAsString());
      // FirebaseService.addDocument handles conversion automatically.
      await FirebaseService.addDocument("restaurants", payload);
      return Response.ok(
        jsonEncode({'message': 'Restaurant added successfully'}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });

  // GET /restaurants/<restaurantId> - Fetch a specific restaurant along with its menu
  router.get('/<restaurantId>', (Request request, String restaurantId) async {
    try {
      print('Function reached for restaurantId: $restaurantId');
      // Fetch the restaurant document; it is already in plain Dart format.
      final restaurant = await FirebaseService.getDocument("restaurants", restaurantId);
      print('Got document: $restaurant');

      if (restaurant == null) {
        return Response.notFound(
          jsonEncode({'error': 'Restaurant not found'}),
        );
      }

      // Fetch the menu subcollection; again, the data is plain Dart types.
      final menuItems = await FirebaseService.getCollection("restaurants/$restaurantId/menu");
      print('Got MENU items');

      // Add the menu items to the restaurant data.
      restaurant['menu'] = menuItems;

      return Response.ok(
        jsonEncode(restaurant),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching restaurant: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });

  // GET /restaurants/<restaurantId>/menu/<menuItemId> - Fetch a specific menu item
  router.get('/<restaurantId>/menu/<menuItemId>', (Request request, String restaurantId, String menuItemId) async {
    try {
      print('Fetching menu item details for restaurant: $restaurantId, menu item: $menuItemId');

      // Fetch the menu item document; already decoded into plain Dart types.
      final menuItem = await FirebaseService.getDocument("restaurants/$restaurantId/menu", menuItemId);

      if (menuItem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Menu item not found'}),
        );
      }

      return Response.ok(
        jsonEncode(menuItem),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching menu item details: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // PATCH /bbm/menu/normalize - Normalize keys in the menu documents for a specific restaurant
  router.patch('/bbm/menu/normalize', (Request request) async {
    try {
      print('Starting normalization of menu documents.');

      // Fetch all documents in the collection; these are already plain Dart maps.
      final List<dynamic> documents = await FirebaseService.getCollection("restaurants/bbm/menu");

      // Iterate over each document.
      for (var doc in documents) {
        // Assume that each document contains an 'id' field.
        final String docId = doc['id'];

        // Create a new map for normalized fields.
        Map<String, dynamic> normalizedFields = {};
        bool needsUpdate = false;

        // Iterate through each field in the document.
        doc.forEach((key, value) {
          // Optionally skip fields you don't want to change (like the 'id').
          if (key == 'id') {
            normalizedFields[key] = value;
          } else {
            // If the key starts with a capital letter, convert the first letter to lowercase.
            if (key.isNotEmpty && key[0] != key[0].toLowerCase()) {
              String newKey = key[0].toLowerCase() + key.substring(1);
              normalizedFields[newKey] = value;
              needsUpdate = true;
            } else {
              normalizedFields[key] = value;
            }
          }
        });

        // If any changes were made, update the document.
        if (needsUpdate) {
          print('Updating document $docId with normalized keys.');
          await FirebaseService.updateDocumentNoMask("restaurants/bbm/menu", docId, normalizedFields);
        } else {
          print('Document $docId does not require normalization.');
        }
      }

      return Response.ok(
        jsonEncode({'message': 'Normalization complete'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error during normalization: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  return router;
}
