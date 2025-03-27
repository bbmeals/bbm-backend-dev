import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../models/address.dart';

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
      print(data);
      print('Reached');

      // Create a User instance from the incoming JSON data
      final newUser = User.fromJson(data);
      print('Used from JSON');

      // Fetch all users from Firestore and search for a matching phone number
      final users = await FirebaseService.getCollection('users');
      print(users);
      print('R1');

      // Directly compare phone values since they are already decoded into plain Dart types
      final matchingUsers = users.where((user) => user['phone'] == newUser.phone).toList();
      print('R2');
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

  router.post('/checkuser', (Request request) async {
    final payload = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final phone = payload['phone'];

    if (phone == null || phone.trim().isEmpty) {
      return Response(400,
          body: jsonEncode({'error': 'Phone number is required'}),
          headers: {'Content-Type': 'application/json'});
    }

    try {
      final users = await FirebaseService.getCollection('users');
      final matchingUsers = users.where((user) => user['phone'] == phone).toList();

      if (matchingUsers.isNotEmpty) {
        return Response.ok(jsonEncode({'exists': true, 'user': matchingUsers.first}),
            headers: {'Content-Type': 'application/json'});
      } else {
        return Response.ok(jsonEncode({'exists': false}),
            headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });


  // Route to add an address directly into the user document
  router.post('/<userId>/address', (Request request, String userId) async {
    print('Inside add/update address for user: $userId');
    try {
      // Read and decode the request body.
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Validate required fields: street, city, pin, and type.
      if (data['street'] == null || (data['street'] as String).trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Street is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (data['city'] == null || (data['city'] as String).trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'City is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (data['pin'] == null || (data['pin'] as String).trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Pin is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (data['type'] == null || (data['type'] as String).trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Address type is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Create an Address instance from the incoming JSON data.
      final newAddress = Address.fromJson(data);
      print('New address: $newAddress');

      // Fetch the user document from Firestore.
      final userDoc = await FirebaseService.getDocument('users', userId);
      if (userDoc == null) {
        return Response(
          404,
          body: jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Retrieve the current addresses map or initialize it if not present.
      Map<String, dynamic> addresses = {};
      if (userDoc['addresses'] != null) {
        addresses = Map<String, dynamic>.from(userDoc['addresses']);
      }
      print('Existing user document:');
      print(userDoc);

      // Add or update the address based on its type.
      addresses[newAddress.type] = newAddress.toJson();
      print('Updated addresses:');
      print(addresses);

      // Merge the updated addresses into the existing user document.
      userDoc['addresses'] = addresses;

      // Update the user document with the merged data using the no-mask helper.
      await FirebaseService.updateDocumentNoMask('users', userId, userDoc);

      return Response.ok(
        jsonEncode({
          'message': 'Address added/updated successfully',
          'addresses': addresses,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error adding address to user: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });


  // Route to fetch all addresses for a user (addresses stored as key-value pairs)
  router.get('/<userId>/addresses', (Request request, String userId) async {
    print('Inside fetch addresses for user: $userId');
    try {
      // Retrieve the user document from Firestore
      final userDoc = await FirebaseService.getDocument('users', userId);
      if (userDoc == null) {
        return Response(
          404,
          body: jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Retrieve the addresses map from the user document.
      // If addresses is not present, default to an empty map.
      Map<String, dynamic> addresses = {};
      if (userDoc['addresses'] != null) {
        addresses = Map<String, dynamic>.from(userDoc['addresses']);
      }

      return Response.ok(
        jsonEncode({
          'message': 'Addresses fetched successfully',
          'addresses': addresses,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error fetching addresses: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });



  return router;
}
