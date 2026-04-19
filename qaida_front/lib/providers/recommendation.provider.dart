import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../shared/constants/recommendation_api.dart';

class RecommendationProvider extends ChangeNotifier {
  List places = [];

  Future<void> getRecommendedPlaces(String userId) async {
    try {
      final response = await http.post(
        Uri.parse(RecommendationApi.recommendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        places = List.from(jsonDecode(response.body));
        notifyListeners();
        return;
      }

      if (kDebugMode) {
        print('Recommendation request failed: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('RecommendationProvider error: $e');
      }
    }
  }

  void clearRecommendations() {
    places.clear();
    notifyListeners();
  }
}