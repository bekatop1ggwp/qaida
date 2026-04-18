import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qaida/data/user.data.dart';

class UserProvider extends ChangeNotifier {
  late User _myself;
  bool _hasMyself = false;

  User get myself => _myself;
  bool get hasMyself => _hasMyself;

  int visitedCount = 0;
  int reviewCount = 0;
  List visitedPlaces = [];

  bool _isLoadingMyself = false;
  bool get isLoadingMyself => _isLoadingMyself;

  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://192.168.8.6:8080';

  Future<void> getMe() async {
    _isLoadingMyself = true;
    notifyListeners();

    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        _hasMyself = false;
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/user/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _myself = User.fromMap(jsonDecode(response.body));
        _hasMyself = true;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('getMe error: $e');
      }
      _hasMyself = false;
      rethrow;
    } finally {
      _isLoadingMyself = false;
      notifyListeners();
    }
  }

  void clearUser() {
    _hasMyself = false;
    visitedCount = 0;
    reviewCount = 0;
    visitedPlaces = [];
    notifyListeners();
  }

  Future<void> fetchVisitedCount() async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        visitedPlaces = [];
        visitedCount = 0;
        reviewCount = 0;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/place/visited'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to load visited: ${response.statusCode}');
      }

      final List visited = List.from(jsonDecode(response.body));

      visitedPlaces = visited.map((visit) {
        final place = Map<String, dynamic>.from(visit['place_id']);
        place['visited_id'] = visit['_id'];
        return place;
      }).toList();

      visitedCount = visited.length;
      reviewCount = visited.where((visit) => visit['status'] == 'VISITED').length;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('fetchVisitedCount error: $e');
      }
      rethrow;
    }
  }

  Future<void> changeUser(User user, bool deactivate) async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      final response = await http.patch(
        Uri.parse('$_baseUrl/api/user/update'),
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

      if (response.statusCode >= 300) {
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      }

      _myself = user;
      _hasMyself = true;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> changeAvatar() async {
    try {
      final token = await _storage.read(key: 'access_token');

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final file = File(image.path);

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseUrl/api/user/avatar'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();

      if (response.statusCode > 300) {
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      } else {
        await getMe();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List> getFavPlaces() async {
    try {
      if (!_hasMyself) return [];

      final favPlaces = [];

      for (final place in _myself.favorites) {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/place/place/${place['_id']}'),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          favPlaces.add(jsonDecode(response.body));
        }
      }

      return favPlaces;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<void> changeFavPlaces(Map place, bool toAdd) async {
    try {
      if (!_hasMyself) {
        throw Exception('User is not loaded');
      }

      final token = await _storage.read(key: 'access_token');

      final favorites = List.from(_myself.favorites);

      if (toAdd) {
        final exists = favorites.any(
          (favPlace) => favPlace['_id'] == place['_id'],
        );
        if (!exists) {
          favorites.add(place);
        }
      } else {
        favorites.removeWhere(
          (favPlace) => favPlace['_id'] == place['_id'],
        );
      }

      final favIds = favorites.map((favPlace) => favPlace['_id']).toList();

      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'place_ids': favIds,
        }),
      );

      if (response.statusCode > 300) {
        throw Exception('${response.statusCode}: ${response.reasonPhrase}');
      }

      await getMe();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }
}