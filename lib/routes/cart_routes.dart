import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
Router cartRoutes() {
  final router = Router();

  // GET /users/<userId>/cart - Get all cart items for a user
  // router.get('/<userId>/cart', (Request request, String userId) async {
  //   try {
  //     final cartItems = await FirebaseService.getCollection("users/$userId/cart");
  //     return Response.ok(jsonEncode(cartItems), headers: {'Content-Type': 'application/json'});
  //   } catch (e) {
  //     return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  //   }
  // });

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

  // router.post('/<userId>/cart', (Request request, String userId) async {
  //   try {
  //     print('Function called');
  //     // Read and decode the incoming payload
  //     final rawPayload = await request.readAsString();
  //     final payload = jsonDecode(rawPayload) as Map<String, dynamic>;
  //     payload['userId'] = userId;
  //
  //     // Set createdAt to the current UTC time if it's not provided
  //     if (!payload.containsKey('createdAt')) {
  //       payload['createdAt'] = DateTime.now().toUtc().toIso8601String();
  //     }
  //
  //     // Validate payload structure using the CartItem model with a dummy id
  //     final validationPayload = Map<String, dynamic>.from(payload);
  //     validationPayload['id'] = 'temp';
  //     CartItem.fromJson(validationPayload);
  //
  //     // Create a CartItem instance for conversion (id is a placeholder)
  //     final cartItem = CartItem(
  //       id: '', // placeholder; Firestore will generate a new id
  //       userId: payload['userId'],
  //       restaurantId: payload['restaurantId'],
  //       itemId: payload['itemId'],
  //       quantity: payload['quantity'],
  //       priceSnapshot: payload['priceSnapshot'],
  //       customization: Map<String, String>.from(payload['customization']),
  //       createdAt: DateTime.parse(payload['createdAt']),
  //     );
  //
  //     // Convert the CartItem to Firestore JSON format and extract the 'fields' map
  //     final firestoreData = cartItem.toFirestoreJson()['fields'];
  //
  //     // Add the document to Firestore using the correctly formatted JSON
  //     final newId = await FirebaseService.addDocument("users/$userId/cart", firestoreData);
  //     payload['id'] = newId;
  //
  //     return Response.ok(jsonEncode(payload), headers: {'Content-Type': 'application/json'});
  //   } catch (e) {
  //     print('Error');
  //     return Response.internalServerError(
  //         body: jsonEncode({'error': e.toString()})
  //     );
  //   }
  // });
  router.post('/<userId>/cart', (Request request, String userId) async {
    try {
      print('Function called');

      // Read and decode the incoming payload
      final rawPayload = await request.readAsString();
      final payload = jsonDecode(rawPayload) as Map<String, dynamic>;
      payload['userId'] = userId;

      // Print all parameters for debugging
      print('Received parameters:');
      print('userId: $userId');
      print('restaurantId: ${payload['restaurantId']}');
      print('itemId: ${payload['itemId']}');
      print('quantity: ${payload['quantity']}');
      print('priceSnapshot: ${payload['priceSnapshot']}');
      print('customization: ${payload['customization']}');

      // Set createdAt to the current UTC time if it's not provided
      if (!payload.containsKey('createdAt')) {
        payload['createdAt'] = DateTime.now().toUtc().toIso8601String();
      }
      print('createdAt: ${payload['createdAt']}');

      // Validate payload structure using the CartItem model with a dummy id
      final validationPayload = Map<String, dynamic>.from(payload);
      validationPayload['id'] = 'temp';
      CartItem.fromJson(validationPayload);

      // Create a CartItem instance for conversion (id is a placeholder)
      final cartItem = CartItem(
        id: '', // placeholder; Firestore will generate a new id
        userId: payload['userId'],
        restaurantId: payload['restaurantId'],
        itemId: payload['itemId'],
        quantity: payload['quantity'],
        priceSnapshot: payload['priceSnapshot'],
        customization: Map<String, String>.from(payload['customization']),
        createdAt: DateTime.parse(payload['createdAt']),
      );

      // Convert the CartItem to Firestore JSON format and extract the 'fields' map
      final firestoreData = cartItem.toFirestoreJson()['fields'];

      // Add the document to Firestore using the correctly formatted JSON
      final newId = await FirebaseService.addDocument("users/$userId/cart", firestoreData);
      payload['id'] = newId;

      return Response.ok(
        jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      // Print the detailed error message for debugging
      print('Error: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  });

  router.post('/adduser', (Request request) async {
    print('inside add user');
    try {
      // Read and decode the incoming request body
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Validate required phone field
      if (data['phone'] == null || (data['phone'] as String).trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Phone number is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Set createdAt to current timestamp if not provided
      data['createdAt'] ??= DateTime.now().toIso8601String();

      // Create a User instance from the incoming JSON data
      final newUser = User.fromJson(data);

      // Fetch all users from Firestore and search for a matching phone number
      final users = await FirebaseService.getCollection('users');
      print(users);

      final matchingUsers = users.where((user) {
        // Extract the phone field value if it exists.
        final phoneField = user['phone'];
        if (phoneField != null && phoneField is Map<String, dynamic>) {
          return phoneField['stringValue'] == newUser.phone;
        }
        return false;
      }).toList();

      print(matchingUsers);

      if (matchingUsers.isNotEmpty) {
        // User exists – return the first matching user's data
        return Response.ok(
          jsonEncode({
            'message': 'User exists, logged in successfully',
            'user': matchingUsers.first,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // If no matching user, add the new user to Firestore
      final userId = await FirebaseService.addDocument('users', newUser.toJson());

      // Build the saved user instance with the returned document id
      final savedUser = User(
        id: userId,
        name: newUser.name,
        email: newUser.email,
        phone: newUser.phone,
        createdAt: newUser.createdAt,
      );

      return Response.ok(
        jsonEncode({
          'message': 'User added successfully',
          'user': savedUser.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error adding user: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });




  // To update quantity of cart
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

      // Check if quantity is 0 and delete the item instead of updating
      if (quantity == null || quantity == 0) {
        print('Removing item: $cartItemId');

        // Remove the item from Firestore
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

      // Update Firestore document for the specified cart item
      await FirebaseService.updateDocument("users/$userId/cart", cartItemId, updateData);

      // Return a response with the updated data (including the cartItemId)
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



  // // Get all values from cart
  // router.get('/<userId>/cart', (Request request, String userId) async {
  //   try {
  //     print('Fetching all cart items for user: $userId');
  //
  //     // Retrieve all cart documents for the given user.
  //     // This should return a list of maps, with each map representing a cart item.
  //     final cartDocuments = await FirebaseService.getCollection("users/$userId/cart");
  //
  //     // Return the list of cart items as JSON.
  //     return Response.ok(
  //       jsonEncode(cartDocuments),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //   } catch (e) {
  //     print('Error fetching cart items: $e');
  //     return Response.internalServerError(
  //       body: jsonEncode({'error': e.toString()}),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //   }
  // });

  router.get('/<userId>/cart', (Request request, String userId) async {
    try {
      print('Fetching all cart items for user: $userId');

      // Retrieve all cart documents, defaulting to an empty list if null.
      final dynamic rawCartDocuments = await FirebaseService.getCollection("users/$userId/cart");
      final List<dynamic> cartDocuments = rawCartDocuments is List<dynamic> ? rawCartDocuments : [];

      List combinedCartData = [];

      for (var cartDoc in cartDocuments) {
        // Extract restaurantId and itemId from the cart document.
        final restaurantId = cartDoc['restaurantId'] is Map
            ? cartDoc['restaurantId']['stringValue']
            : cartDoc['restaurantId'];
        final itemId = cartDoc['itemId'] is Map
            ? cartDoc['itemId']['stringValue']
            : cartDoc['itemId'];

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













  return router;
}
