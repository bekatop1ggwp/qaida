import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:qaida/core/api_config.dart';


class CategoryProvider extends ChangeNotifier {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  List categories = [];
  List topPlaces = [];
  final Map<String, List> _placesByCategory = {};

  bool _isScreenLoading = false;
  bool _isInitialDataLoaded = false;

  bool get isScreenLoading => _isScreenLoading;
  bool get isInitialDataLoaded => _isInitialDataLoaded;

  List getPlacesForCategory(String categoryId) {
    return _placesByCategory[categoryId] ?? [];
  }

  bool hasPlacesForCategory(String categoryId) {
    return _placesByCategory.containsKey(categoryId);
  }

  Future<void> loadCategoriesScreen({bool forceRefresh = false}) async {
    if (_isScreenLoading) return;
    if (_isInitialDataLoaded && !forceRefresh) return;

    _isScreenLoading = true;

    if (forceRefresh) {
      categories = [];
      topPlaces = [];
      _placesByCategory.clear();
      _isInitialDataLoaded = false;
    }

    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/catalog?previewLimit=6&topLimit=3'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Catalog loading failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      categories = List.from(decoded['categories'] ?? []);
      topPlaces = List.from(decoded['topPlaces'] ?? []);

      _placesByCategory.clear();

      final rawPlacesByCategory = decoded['placesByCategory'] ?? {};

      if (rawPlacesByCategory is Map) {
        rawPlacesByCategory.forEach((key, value) {
          _placesByCategory[key.toString()] = List.from(value ?? []);
        });
      }

      _isInitialDataLoaded = true;
    } catch (e) {
      debugPrint('loadCategoriesScreen error: $e');
    } finally {
      _isScreenLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getCategoryPlacesPage({
    required String rubricId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/place/category-page?rubric_id=$rubricId&page=$page&limit=$limit',
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Category page loading failed: ${response.statusCode}');
    }

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<void> refreshCategoriesScreen() async {
    await loadCategoriesScreen(forceRefresh: true);
  }
}