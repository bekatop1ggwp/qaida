import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RecommendationProvider extends ChangeNotifier {
  List places = [];

  Future<void> getRecommendedPlaces(String userId) async {
    try {
      http.Response response = await http.post(
        Uri.parse('http://192.168.8.6:8001/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({ 'user_id': userId }),
      );
      places = List.from(jsonDecode(response.body));
      notifyListeners();
    } catch(e) {
      if (kDebugMode) print(e);
    }
  }

  void clearRecommendations() {
    places.clear();
    notifyListeners();
  }
}
