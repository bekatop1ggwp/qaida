import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PlaceProvider extends ChangeNotifier {
  late String id;

  Map? place;
  List reviews = [];
  List reviewsPreview = [];
  List interestingPlaces = [];

  int reviewCount = 0;
  double averageRating = 0;

  static const String _baseUrl = 'http://192.168.8.6:8080';

  void setId(String id) {
    this.id = id;

    place = null;
    reviews = [];
    reviewsPreview = [];
    interestingPlaces = [];
    reviewCount = 0;
    averageRating = 0;

    notifyListeners();
  }

  Future<void> getPlaceDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/place/$id/details'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Place details loading failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid place details response');
      }

      place = decoded['place'] == null ? null : Map.from(decoded['place']);
      reviews = List.from(decoded['reviews'] ?? []);
      reviewsPreview = List.from(decoded['reviewsPreview'] ?? []);
      interestingPlaces = List.from(decoded['interestingPlaces'] ?? []);

      reviewCount = decoded['reviewCount'] is num
          ? decoded['reviewCount']
          : int.tryParse(decoded['reviewCount']?.toString() ?? '0') ?? 0;

      averageRating = decoded['averageRating'] is num
          ? decoded['averageRating'].toDouble()
          : double.tryParse(decoded['averageRating']?.toString() ?? '0') ?? 0;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  // Можно оставить старые методы, если они где-то еще используются

  Future<void> getPlaceById() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/place/$id'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Place loading failed: ${response.statusCode}');
      }

      place = Map.from(jsonDecode(response.body));
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

      return List.from(jsonDecode(response.body));
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

      reviews = List.from(jsonDecode(response.body));
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