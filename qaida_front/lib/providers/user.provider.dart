import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qaida/data/user.data.dart';

class UserProvider extends ChangeNotifier {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://192.168.8.6:8080';

  static const String _cachedUserKey = 'cached_user';
  static const String _cachedVisitedCountKey = 'cached_visited_count';
  static const String _cachedReviewCountKey = 'cached_review_count';
  static const String _cachedVisitedPlacesKey = 'cached_visited_places';

  late User _myself;
  bool _hasMyself = false;

  User get myself => _myself;
  bool get hasMyself => _hasMyself;

  bool _isLoadingMyself = false;
  bool get isLoadingMyself => _isLoadingMyself;

  int visitedCount = 0;
  int reviewCount = 0;
  List visitedPlaces = [];

  Future<void> loadCachedProfile() async {
    final sw = Stopwatch()..start();

    try {
      final cachedUser = await _storage.read(key: _cachedUserKey);
      final cachedVisitedCount = await _storage.read(key: _cachedVisitedCountKey);
      final cachedReviewCount = await _storage.read(key: _cachedReviewCountKey);
      final cachedVisitedPlaces = await _storage.read(key: _cachedVisitedPlacesKey);

      bool hasAnyCache = false;

      if (cachedUser != null && cachedUser.isNotEmpty) {
        try {
          final rawMap = Map<String, dynamic>.from(jsonDecode(cachedUser));
          final normalized = _normalizeCachedUserMap(rawMap);
          _myself = User.fromMap(normalized);
          _hasMyself = true;
          hasAnyCache = true;
        } catch (e) {
          if (kDebugMode) {
            print('[PROFILE][UserProvider] cached user parse error: $e');
          }
          _hasMyself = false;
          await _storage.delete(key: _cachedUserKey);
        }
      }

      if (cachedVisitedCount != null) {
        visitedCount = int.tryParse(cachedVisitedCount) ?? 0;
        hasAnyCache = true;
      }

      if (cachedReviewCount != null) {
        reviewCount = int.tryParse(cachedReviewCount) ?? 0;
        hasAnyCache = true;
      }

      if (cachedVisitedPlaces != null && cachedVisitedPlaces.isNotEmpty) {
        try {
          visitedPlaces = List.from(jsonDecode(cachedVisitedPlaces));
          hasAnyCache = true;
        } catch (_) {
          visitedPlaces = [];
          await _storage.delete(key: _cachedVisitedPlacesKey);
        }
      }

      if (hasAnyCache) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PROFILE][UserProvider] loadCachedProfile error: $e');
      }
    } finally {
      if (kDebugMode) {
        print('[PROFILE][UserProvider] loadCachedProfile: ${sw.elapsedMilliseconds} ms');
      }
    }
  }

  Future<void> _saveCachedUser() async {
    if (!_hasMyself) return;
    await _storage.write(
      key: _cachedUserKey,
      value: jsonEncode(_myself.toMap()),
    );
  }

  Future<void> _saveCachedVisitedMeta() async {
    await _storage.write(
      key: _cachedVisitedCountKey,
      value: visitedCount.toString(),
    );
    await _storage.write(
      key: _cachedReviewCountKey,
      value: reviewCount.toString(),
    );
    await _storage.write(
      key: _cachedVisitedPlacesKey,
      value: jsonEncode(visitedPlaces),
    );
  }

  Future<void> getMe({bool silent = false}) async {
    final sw = Stopwatch()..start();

    _isLoadingMyself = true;
    if (!silent) notifyListeners();

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
        await _saveCachedUser();
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
      if (!silent) notifyListeners();
      if (kDebugMode) {
        print('[PROFILE][UserProvider] getMe: ${sw.elapsedMilliseconds} ms');
      }
    }
  }

  Future<void> fetchVisitedCount({bool silent = false}) async {
    final sw = Stopwatch()..start();

    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        visitedPlaces = [];
        visitedCount = 0;
        reviewCount = 0;
        if (!silent) notifyListeners();
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

      await _saveCachedVisitedMeta();

      if (!silent) notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('fetchVisitedCount error: $e');
      }
      rethrow;
    } finally {
      if (kDebugMode) {
        print(
          '[PROFILE][UserProvider] fetchVisitedCount: ${sw.elapsedMilliseconds} ms',
        );
      }
    }
  }

  Future<void> refreshProfileInBackground() async {
    final sw = Stopwatch()..start();

    try {
      await Future.wait([
        getMe(silent: true),
        fetchVisitedCount(silent: true),
      ]);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[PROFILE][UserProvider] refreshProfileInBackground error: $e');
      }
    } finally {
      if (kDebugMode) {
        print(
          '[PROFILE][UserProvider] refreshProfileInBackground total: ${sw.elapsedMilliseconds} ms',
        );
      }
    }
  }

  void notifyProfileReady() {
    notifyListeners();
  }

  Future<void> clearUser() async {
    _hasMyself = false;
    visitedCount = 0;
    reviewCount = 0;
    visitedPlaces = [];

    await _storage.delete(key: _cachedUserKey);
    await _storage.delete(key: _cachedVisitedCountKey);
    await _storage.delete(key: _cachedReviewCountKey);
    await _storage.delete(key: _cachedVisitedPlacesKey);

    notifyListeners();
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
      await _saveCachedUser();
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
      }

      await getMe();
    } catch (e) {
      if (kDebugMode) print(e);
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
      if (kDebugMode) print(e);
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
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Map<String, dynamic> _normalizeCachedUserMap(Map<String, dynamic> raw) {
    return {
      ...raw,
      'name': raw['name'] ?? '',
      'surname': raw['surname'] ?? '',
      'father_name': raw['father_name'] ?? '',
      'password': raw['password'] ?? '',
      'email': raw['email'] ?? '',
      'messenger_one': raw['messenger_one'] ?? '',
      'messenger_two': raw['messenger_two'] ?? '',
      'gender': raw['gender'] ?? 'BINARY',
      'favorites': raw['favorites'] ?? [],
      'friends': raw['friends'] ?? [],
      'interests': raw['interests'] ?? [],
    };
  }
}