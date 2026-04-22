import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReviewProvider extends ChangeNotifier {
  static const String _baseUrl = 'http://192.168.8.6:8080';

  List processing = [];
  int reviewCount = 0;

  Future<void> _changeVisitedStatus(
    String visitedId,
    String placeId,
    String status,
  ) async {
    try {
      final String? token =
          await const FlutterSecureStorage().read(key: 'access_token');

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
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<void> getProcessingPlaces() async {
    final String? token =
        await const FlutterSecureStorage().read(key: 'access_token');

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

    reviewCount = processing.length;
    notifyListeners();
  }

  Future<void> sendRating(String visitedId, String placeId, int rating) async {
    try {
      final String? token =
          await const FlutterSecureStorage().read(key: 'access_token');

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
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<void> skip(String visitedId, String placeId) async {
    await _changeVisitedStatus(visitedId, placeId, 'SKIP');
  }
}