import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class FirebaseService {
  static const String projectId = "bbm-db-dev"; // 🔥 Replace with your Firebase Project ID
  static const String apiKey = "AIzaSyCfU0FvHfoG0uvCcETG6pWr8xUZtNSBix0";
  static String get firestoreUrl => "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents";

  static Future<List<Map<String, dynamic>>> getCollection(String collectionName) async {
    final url = Uri.parse("$firestoreUrl/$collectionName?key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic>? documents = data['documents'] as List<dynamic>?;
      if (documents == null) return []; // Return an empty list if no documents found

      return documents.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>;
        final name = doc['name'] as String;
        final id = name.split('/').last; // Extract the document ID from the full path
        return {
          ...fields,
          'id': id,
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch data: ${response.body}");
    }
  }


  /// Fetch a single document from a Firestore collection
  static Future<Map<String, dynamic>?> getDocument(String collectionName, String docId) async {
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey");
    final response = await http.get(url);
    print(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['fields'];
    } else {
      return null;
    }
  }

  /// Add a new document to Firestore and return the new document's id
  static Future<String> addDocument(String collectionName, Map<String, dynamic> data) async {
    final url = Uri.parse("$firestoreUrl/$collectionName?key=$apiKey");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': data}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add data: ${response.body}");
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final documentName = responseData['name'] as String;
    final parts = documentName.split('/');
    final documentId = parts.last;
    return documentId;
  }
  /// Update a Firestore document
  static Future<void> updateDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    // Append update mask to update only the 'quantity' field
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey&updateMask.fieldPaths=quantity");

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
  static Future<void> deleteDocument(String collectionName, String docId) async {
    final url = Uri.parse("$firestoreUrl/$collectionName/$docId?key=$apiKey");

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data: ${response.body}");
    }
  }
}
