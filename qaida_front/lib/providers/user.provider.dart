import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qaida/data/user.data.dart';

class UserProvider extends ChangeNotifier {
  late User myself;
  int visitedCount = 0;
  int reviewCount = 0;
  List visitedPlaces = [];

  Future<void> getMe() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    http.Response response = await http.get(
      Uri.parse('http://192.168.8.6:8080/api/user/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    myself = User.fromMap(jsonDecode(response.body));
  }

  Future<void> fetchVisitedCount() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    http.Response response = await http.get(
      Uri.parse('http://192.168.8.6:8080/api/place/visited'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    List visited = List.from(jsonDecode(response.body));
    visitedPlaces = visited.map((visit) {
      final place = visit['place_id'];
      place['visited_id'] = visit['_id'];
      return place;
    }).toList();
    visitedCount = visited.length;
    reviewCount =
        visited.map((visit) => visit['status'] == 'VISITED').toList().length;
  }

  Future changeUser(User user, bool deactivate) async {
    try {
      const storage = FlutterSecureStorage();
      final String? token = await storage.read(key: 'access_token');
      await http.patch(
        Uri.parse('http://192.168.8.6:8080/api/user/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          '_id': user.id,
          'isDiactivated': deactivate,
          'name': user.name,
          'surname': user.surname,
          'father_name': user.fatherName,
          'password': user.password,
          'email': user.email,
          'messenger_one': user.messengerOne,
          'messenger_two': user.messengerTwo,
          'gender': user.gender,
        }),
      );
      myself = user;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future changeAvatar() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      final file = File(image!.path);

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://192.168.8.6:8080/api/user/avatar'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      var response = await request.send();

      if (response.statusCode > 300) {
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      } else {
        await getMe();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future getFavPlaces() async {
    try {
      final favPlaces = [];
      for (var place in myself.favorites) {
        final response = await http.get(
          Uri.parse('http://192.168.8.6:8080/api/place/place/${place['_id']}'),
        );
        favPlaces.add(jsonDecode(response.body));
      }
      return favPlaces;
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future changeFavPlaces(Map place, bool toAdd) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');

      if (toAdd) {
        myself.favorites.add(place);
      } else {
        myself.favorites.removeWhere(
          (favPlace) => favPlace['_id'] == place['_id'],
        );
      }

      final favIds = [];
      for (var place in myself.favorites) {
        favIds.add(place['_id']);
      }


      final response = await http.put(
        Uri.parse('http://192.168.8.6:8080/api/user/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-type': 'application/json'
        },
        body: jsonEncode({
          'place_ids': favIds,
        }),
      );
      if (response.statusCode > 300) {
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }
}
