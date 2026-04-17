import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReviewProvider extends ChangeNotifier {
  List processing = [];
  int reviewCount = 0;

  Future _changeVisitedStatus(
    String visitedId,
    String placeId,
    String status,
  ) async {
    try {
      String? token =
          await const FlutterSecureStorage().read(key: 'access_token');

      await http.put(
        Uri.parse('http://192.168.8.6:8080/api/place/visited/$visitedId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status.toUpperCase()}),
      );

      processing.removeWhere((place) => place['_id'] == placeId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future getProcessingPlaces() async {
    String? token =
        await const FlutterSecureStorage().read(key: 'access_token');

    http.Response response = await http.get(
      Uri.parse('http://192.168.8.6:8080/api/place/visited'),
      headers: {'Authorization': 'Bearer $token'},
    );

    List visited = List.from(jsonDecode(response.body));
    List processing = List.from(
      visited.where((data) => data['status'] == 'PROCESSING'),
    );
    this.processing = processing.map((data) {
      Map result = data['place_id'];
      result['visited_id'] = data['_id'];
      return result;
    }).toList();
    notifyListeners();
  }

  Future sendRating(String visitedId, String placeId, int rating) async {
    try {
      String? token =
          await const FlutterSecureStorage().read(key: 'access_token');

      await http.post(
        Uri.parse('http://192.168.8.6:8080/api/review'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'place_id': placeId,
          'comment': '',
          'score': rating,
        }),
      );

      await _changeVisitedStatus(visitedId, placeId, 'VISITED');
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future skip(String visitedId, String placeId) async {
    await _changeVisitedStatus(visitedId, placeId, 'SKIP');
  }
}
