import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../shared/constants/recommendation_api.dart';

class RecommendationProvider extends ChangeNotifier {
  List places = [];
  bool isLoading = false;
  bool hasLoadedOnce = false;

  int _requestId = 0;

  Future<void> getRecommendedPlaces(String userId) async {
    final currentRequestId = ++_requestId;

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(RecommendationApi.recommendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (currentRequestId != _requestId) return;

      if (kDebugMode) {
        print('[REC PERSONALIZED] status: ${response.statusCode}');
        print('[REC PERSONALIZED] body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        places = decoded is List ? List.from(decoded) : [];
      } else {
        places = [];
      }
    } catch (e, st) {
      if (currentRequestId != _requestId) return;

      places = [];
      if (kDebugMode) {
        print('RecommendationProvider personalized error: $e');
        print(st);
      }
    } finally {
      if (currentRequestId == _requestId) {
        isLoading = false;
        hasLoadedOnce = true;
        notifyListeners();
      }
    }
  }

  Future<void> getPopularPlaces() async {
    final currentRequestId = ++_requestId;

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${RecommendationApi.recommendationBaseUrl}/popular'),
      );

      if (currentRequestId != _requestId) return;

      if (kDebugMode) {
        print('[REC POPULAR] status: ${response.statusCode}');
        print('[REC POPULAR] body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        places = decoded is List ? List.from(decoded) : [];
      } else {
        places = [];
      }
    } catch (e, st) {
      if (currentRequestId != _requestId) return;

      places = [];
      if (kDebugMode) {
        print('RecommendationProvider popular error: $e');
        print(st);
      }
    } finally {
      if (currentRequestId == _requestId) {
        isLoading = false;
        hasLoadedOnce = true;
        notifyListeners();
      }
    }
  }

  void clearRecommendations({bool notify = true}) {
    _requestId++;
    places.clear();
    isLoading = false;

    if (notify) {
      notifyListeners();
    }
  }
}