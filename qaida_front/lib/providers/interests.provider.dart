import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InterestsProvider extends ChangeNotifier {
  static const String _baseUrl = 'http://192.168.8.6:8080';

  List interests = [];
  List<bool> openItems = [];
  List<bool> selectedItems = [];

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  void changeOpen(int index) {
    openItems[index] = !openItems[index];
    notifyListeners();
  }

  void changeSelect(int index) {
    selectedItems[index] = !selectedItems[index];
    notifyListeners();
  }

  List subcategories(int index) {
    return interests[index]['categories'] ?? [];
  }

  List<String> getSelectedIds() {
    final List<String> selectedIds = [];

    for (var i = 0; i < interests.length; i++) {
      if (selectedItems[i]) {
        selectedIds.add(interests[i]['_id'].toString());
      }
    }

    return selectedIds;
  }

  Future<void> fetchInterests({bool force = false}) async {
    if (_isLoaded && !force) return;

    final response = await http.get(
      Uri.parse('$_baseUrl/api/categories?q='),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load interests: ${response.statusCode}');
    }

    interests = jsonDecode(response.body);
    openItems = List<bool>.filled(interests.length, false);
    selectedItems = List<bool>.filled(interests.length, false);
    _isLoaded = true;

    notifyListeners();
  }

  Future<void> sendInterests(String token, List<String> interests) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/user/interest'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'interests': interests,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to save interests: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }

  void applyUserInterests(List userInterests) {
    if (interests.isEmpty) return;

    selectedItems = List<bool>.filled(interests.length, false);

    final selectedIds = userInterests
        .map((interest) => interest['_id']?.toString())
        .whereType<String>()
        .toSet();

    for (var i = 0; i < interests.length; i++) {
      final currentId = interests[i]['_id']?.toString();
      selectedItems[i] = selectedIds.contains(currentId);
    }

    notifyListeners();
  }

  void reset() {
    interests = [];
    openItems = [];
    selectedItems = [];
    _isLoaded = false;
    notifyListeners();
  }
}