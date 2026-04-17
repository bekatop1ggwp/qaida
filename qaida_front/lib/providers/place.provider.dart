import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PlaceProvider extends ChangeNotifier {
  late String id;
  Map? place;
  List reviews = [];

  void setId(String id) {
    this.id = id;
    notifyListeners();
  }

  Future<void> getPlaceById() async {
    try {
      http.Response response = await http.get(
        Uri.parse('http://192.168.8.6:8080/api/place/place/$id'),
      );
      place = Map.from(jsonDecode(response.body));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future getInterestingPlaces(String categoryId) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          'http://192.168.8.6:8080/api/place/search-category?category_id=$categoryId',
        ),
      );
      return List.from(jsonDecode(response.body));
    } catch(e) {
      if (kDebugMode) print(e);
    }
  }

  Future<List> getPlaceReview() async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          'http://192.168.8.6:8080/api/review/$id',
        ),
      );
      List reviews = List.from(jsonDecode(response.body));
      this.reviews = reviews;
      return reviews;
    } catch(_) {
      rethrow;
    }
  }

  Future voteReview(String reviewId, String type) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'access_token');

      await http.post(
        Uri.parse('http://192.168.8.6:8080/api/review/vote/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': type,
        }),
      );
    } catch(e) {
      if (kDebugMode) print(e);
    }
  }

}
