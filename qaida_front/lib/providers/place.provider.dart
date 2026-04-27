import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PlaceProvider extends ChangeNotifier {
  late String id;
  Map? place;
  List reviews = [];
  List interestingPlaces = [];

  static const String _baseUrl = 'http://192.168.8.6:8080';

  void setId(String id) {
    this.id = id;
    place = null;
    reviews = [];
    interestingPlaces = [];
    notifyListeners();
  }

  Future<void> getPlaceById() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/place/$id'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Place loading failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid place response');
      }

      place = Map.from(decoded);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<List> getInterestingPlaces(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/search-category?category_id=$categoryId'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Interesting places loading failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid interesting places response');
      }

      interestingPlaces = List.from(decoded);
      return interestingPlaces;
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<List> getPlaceReview() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/review/$id'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Reviews loading failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid reviews response');
      }

      reviews = List.from(decoded);
      return reviews;
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<void> voteReview(String reviewId, String type) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/review/vote/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'type': type,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Vote failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }
}