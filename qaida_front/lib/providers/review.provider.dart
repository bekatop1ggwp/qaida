import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:qaida/core/api_config.dart';

class ReviewProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List processing = [];
  List myReviews = [];
  int reviewCount = 0;

  double _parseScore(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    if (value is Map && value.containsKey(r'$numberDecimal')) {
      return double.tryParse(value[r'$numberDecimal'].toString()) ?? 0;
    }
    return 0;
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> _changeVisitedStatus(
    String visitedId,
    String placeId,
    String status,
  ) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/place/visited/$visitedId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status.toUpperCase()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update visit status: ${response.statusCode} ${response.body}',
      );
    }

    processing.removeWhere((place) => place['_id'] == placeId);
    notifyListeners();
  }

  Future<void> getProcessingPlaces() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/place/visited?status=PROCESSING'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load processing places: ${response.statusCode} ${response.body}',
      );
    }

    final List visited = List.from(jsonDecode(response.body));

    processing = visited.map((data) {
      final result = Map<String, dynamic>.from(data['place_id']);
      result['visited_id'] = data['_id'];
      result['status'] = data['status'];
      return result;
    }).toList();

    notifyListeners();
  }

  Future<void> getMyReviews() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/review/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to load my reviews: ${response.statusCode} ${response.body}',
      );
    }

    final List reviews = List.from(jsonDecode(response.body));

    myReviews = reviews.map((data) {
      final place = Map<String, dynamic>.from(data['place_id']);
      place['review_id'] = data['_id'];
      place['review_score'] = _parseScore(data['score']);
      place['review_comment'] = data['comment'];
      place['review_created_at'] = data['created_at'];
      return place;
    }).toList();

    reviewCount = myReviews.length;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      getProcessingPlaces(),
      getMyReviews(),
    ]);
  }

  Future<void> sendRating(String visitedId, String placeId, int rating) async {
    final token = await _getToken();

    final reviewResponse = await http.post(
      Uri.parse('$_baseUrl/api/review'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'place_id': placeId,
        'comment': '',
        'score': rating,
      }),
    );

    if (reviewResponse.statusCode < 200 || reviewResponse.statusCode >= 300) {
      throw Exception(
        'Failed to create review: ${reviewResponse.statusCode} ${reviewResponse.body}',
      );
    }

    await _changeVisitedStatus(visitedId, placeId, 'VISITED');
    await refreshAll();
  }

  Future<void> skip(String visitedId, String placeId) async {
    await _changeVisitedStatus(visitedId, placeId, 'SKIP');
    await getProcessingPlaces();
  }

  Future<void> createDemoSuggestions({int count = 5}) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/place/visited/demo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'count': count}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to create demo suggestions: ${response.statusCode} ${response.body}',
      );
    }

    await refreshAll();
  }
}