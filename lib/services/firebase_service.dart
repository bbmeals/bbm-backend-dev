import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FirebaseService {
  // Get project ID and API key from environment variables if available
  static String get projectId =>
      Platform.environment['FIREBASE_PROJECT_ID'] ?? "bbm-db-dev";
  static String get apiKey =>
      Platform.environment['FIREBASE_API_KEY'] ??
      "AIzaSyCfU0FvHfoG0uvCcETG6pWr8xUZtNSBix0";
  static String get firestoreUrl =>
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";

  /// Fetch all documents from a Firestore collection
  static Future<List<Map<String, dynamic>>> getCollection(
      String collectionName) async {
    final url = Uri.parse("$firestoreUrl/$collectionName?key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle the case where there are no documents
      if (!data.containsKey('documents') || data['documents'] == null) {
        return [];
      }
      return (data['documents'] as List)
          .map((doc) => doc['fields'] as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception("Failed to fetch data: ${response.body}");
    }
  }

  /// Fetch a single document from a Firestore collection
  static Future<Map<String, dynamic>?> getDocument(
      String collectionName, String docId) async {
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['fields'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Failed to fetch document: ${response.body}");
    }
  }

  /// Add a new document to Firestore
  static Future<void> addDocument(
      String collectionName, Map<String, dynamic> data) async {
    final url = Uri.parse("$firestoreUrl/$collectionName?key=$apiKey");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': data}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add data: ${response.body}");
    }
  }

  /// Update a Firestore document
  static Future<void> updateDocument(
      String collectionName, String docId, Map<String, dynamic> data) async {
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey");

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': data}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update data: ${response.body}");
    }
  }

  /// Delete a Firestore document
  static Future<void> deleteDocument(
      String collectionName, String docId) async {
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey");

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data: ${response.body}");
    }
  }
}
