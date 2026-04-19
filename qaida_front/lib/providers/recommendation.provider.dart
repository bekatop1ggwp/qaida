import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../shared/constants/recommendation_api.dart';

class RecommendationProvider extends ChangeNotifier {
  List places = [];
  bool isLoading = false;
  bool hasLoadedOnce = false;

  Future<void> getRecommendedPlaces(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(RecommendationApi.recommendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (kDebugMode) {
        print('[REC] status: ${response.statusCode}');
        print('[REC] body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          places = List.from(decoded);
        } else {
          places = [];
        }
      } else {
        places = [];
        if (kDebugMode) {
          print('Recommendation request failed: ${response.statusCode}');
          print(response.body);
        }
      }
    } catch (e, st) {
      places = [];
      if (kDebugMode) {
        print('RecommendationProvider error: $e');
        print(st);
      }
    } finally {
      isLoading = false;
      hasLoadedOnce = true;
      notifyListeners();
    }
  }

  void clearRecommendations({bool notify = true}) {
    places.clear();
    if (notify) {
      notifyListeners();
    }
  }
}