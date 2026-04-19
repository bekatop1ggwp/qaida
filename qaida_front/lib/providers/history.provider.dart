import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HistoryProvider extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://192.168.8.6:8080';

  final Map<String, Map<String, dynamic>> _placesCache = {};
  List<Map<String, dynamic>> history = [];

  Future<Map<String, dynamic>> getPlaceById(String id) async {
    if (_placesCache.containsKey(id)) {
      return _placesCache[id]!;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/place/place/$id'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load place $id: ${response.statusCode}');
    }

    final place = Map<String, dynamic>.from(jsonDecode(response.body));
    _placesCache[id] = place;
    return place;
  }

  Future<List<String>> _getHistoryIds() async {
    final bool hasHistory = await _storage.containsKey(key: 'history');
    if (!hasHistory) return [];

    final String? historyJson = await _storage.read(key: 'history');
    if (historyJson == null || historyJson.isEmpty) return [];

    return List<String>.from(jsonDecode(historyJson));
  }

  Future<void> loadHistory() async {
    final ids = await _getHistoryIds();

    if (ids.isEmpty) {
      history = [];
      notifyListeners();
      return;
    }

    final places = await Future.wait(
      ids.map((id) => getPlaceById(id)),
    );

    history = places;
    notifyListeners();
  }

  Future<void> addHistory(String placeId) async {
    List<String> ids = await _getHistoryIds();

    ids.remove(placeId);
    ids = [placeId, ...ids];

    if (ids.length > 5) {
      ids = ids.take(5).toList();
    }

    await _storage.write(
      key: 'history',
      value: jsonEncode(ids),
    );

    if (_placesCache.containsKey(placeId)) {
      final cachedPlace = _placesCache[placeId]!;
      history.removeWhere((place) => place['_id'] == placeId);
      history = [cachedPlace, ...history].take(5).toList();
      notifyListeners();
    }
  }

  void clearHistoryCache() {
    _placesCache.clear();
    history = [];
    notifyListeners();
  }
}