import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InterestsProvider extends ChangeNotifier {
  List interests = [];
  List<bool> openItems = [];
  List<bool> selectedItems = [];

  void changeOpen(int index) {
    openItems[index] = !openItems[index];
    notifyListeners();
  }

  void changeSelect(int index) {
    selectedItems[index] = !selectedItems[index];
    notifyListeners();
  }

  subcategories(int index) {
    return interests[index]['categories'];
  }

  List<String> getSelectedIds() {
    List<String> selectedIds = [];
    for (var i = 0; i < interests.length; i++) {
      if (selectedItems[i]) {
        selectedIds.add(interests[i]['_id']);
      }
    }
    return selectedIds;
  }

  Future<void> fetchInterests() async {
    final response = await http.get(
      Uri.parse("http://192.168.8.6:8080/api/categories?q="),
    );
    interests = jsonDecode(response.body);
    openItems = List<bool>.filled(interests.length, false);
    selectedItems = List<bool>.filled(interests.length, false);
    notifyListeners();
  }

  Future sendInterests(String token, List<String> interests) async {
    await http.put(
      Uri.parse('http://192.168.8.6:8080/api/user/interest'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token',
      },
      body: Uri(
        queryParameters: {
          'interests': interests,
        },
      ).query,
    );
  }

  void getUserInterests(List interests) {
    if (interests.isEmpty) return;
    for (var interest in interests) {
      if (interest['name'] == 'Спокойный отдых') {
        selectedItems[0] = true;
      } else if (interest['name'] == 'Еда и напитки') {
        selectedItems[1] = true;
      } else if (interest['name'] == 'Спорт') {
        selectedItems[2] = true;
      } else if (interest['name'] == 'Социальные') {
        selectedItems[3] = true;
      } else {
        // Активный отдых
        selectedItems[4] = true;
      }
    }
    notifyListeners();
  }
}