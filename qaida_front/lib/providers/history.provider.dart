import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HistoryProvider extends ChangeNotifier {

  Future<Map> getPlaceById(String id) async {
    try {
      http.Response response = await http.get(
        Uri.parse('http://192.168.8.6:8080/api/place/place/$id'),
      );
      return Map.from(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getHistory() async {
    const storage = FlutterSecureStorage();
    final bool hasHistory = await storage.containsKey(key: 'history');
    if (!hasHistory) return [];

    final String? historyJson = await storage.read(key: 'history');
    List ids = jsonDecode(historyJson!);
    List<Map> places = [];

    for (String id in ids) {
      Map temp = await getPlaceById(id);
      places.add(temp);
    }

    return places;
  }

  Future _getHistoryIds() async {
    const storage = FlutterSecureStorage();
    final bool hasHistory = await storage.containsKey(key: 'history');
    if (!hasHistory) return [];

    final String? historyJson = await storage.read(key: 'history');

    return jsonDecode(historyJson!);
  }

  Future<void> addHistory(String place) async {
    const storage = FlutterSecureStorage();
    List history = await _getHistoryIds();

    history = [place, ...history];
    if (history.length > 5) history.removeLast();

    final String historyJson = jsonEncode(history);
    await storage.write(key: 'history', value: historyJson);

    notifyListeners();
  }

}