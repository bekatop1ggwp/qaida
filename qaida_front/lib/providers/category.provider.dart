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

  Future<void> getCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/categories?q='),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      categories = List.from(jsonDecode(response.body));
      notifyListeners();
      return;
    }

    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  Future<List> getPlacesByCategories(String categoryId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/api/place/search-category?rubric_id=$categoryId',
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return List.from(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to load places for category $categoryId: ${response.statusCode}',
    );
  }

  Future<void> getTopPlaces() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/place/top'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      topPlaces = List.from(jsonDecode(response.body));
      notifyListeners();
      return;
    }

    throw Exception('Failed to load top places: ${response.statusCode}');
  }

  Future<void> _loadPlacesByCategoriesInBatches({
    int batchSize = 4,
  }) async {
    for (int i = 0; i < categories.length; i += batchSize) {
      final batch = categories.skip(i).take(batchSize);

      await Future.wait(
        batch.map((category) async {
          final categoryId = category['_id'].toString();
          final places = await getPlacesByCategories(categoryId);
          _placesByCategory[categoryId] = places;
        }),
      );

      notifyListeners();
    }
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
      final results = await Future.wait([
        http.get(Uri.parse('$_baseUrl/api/categories?q=')),
        http.get(Uri.parse('$_baseUrl/api/place/top')),
      ]);

      final categoriesResponse = results[0];
      final topPlacesResponse = results[1];

      if (categoriesResponse.statusCode < 200 ||
          categoriesResponse.statusCode >= 300) {
        throw Exception(
          'Failed to load categories: ${categoriesResponse.statusCode}',
        );
      }

      if (topPlacesResponse.statusCode < 200 ||
          topPlacesResponse.statusCode >= 300) {
        throw Exception(
          'Failed to load top places: ${topPlacesResponse.statusCode}',
        );
      }

      categories = List.from(jsonDecode(categoriesResponse.body));
      topPlaces = List.from(jsonDecode(topPlacesResponse.body));

      _isInitialDataLoaded = true;
      _isScreenLoading = false;
      notifyListeners();

      await _loadPlacesByCategoriesInBatches(batchSize: 4);
    } catch (e) {
      debugPrint('loadCategoriesScreen error: $e');
      _isScreenLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCategoriesScreen() async {
    await loadCategoriesScreen(forceRefresh: true);
  }
}