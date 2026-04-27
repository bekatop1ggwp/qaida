import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qaida/data/user.data.dart';
import 'package:qaida/core/api_config.dart';

class UserProvider extends ChangeNotifier {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = ApiConfig.apiBaseUrl;

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

  bool _cacheHydrated = false;
  bool get cacheHydrated => _cacheHydrated;

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Map<String, dynamic> _normalizeCachedUserMap(Map<String, dynamic> raw) {
    return {
      ...raw,
      '_id': raw['_id'] ?? raw['id'] ?? '',
      'name': _safeString(raw['name']),
      'surname': _safeString(raw['surname']),
      'father_name': _safeString(raw['father_name']),
      'password': _safeString(raw['password']),
      'email': _safeString(raw['email']),
      'messenger_one': _safeString(raw['messenger_one']),
      'messenger_two': _safeString(raw['messenger_two']),
      'gender': raw['gender'] ?? 'BINARY',
      'image_id': raw['image_id'],
      'favorites': raw['favorites'] ?? [],
      'friends': raw['friends'] ?? [],
      'interests': raw['interests'] ?? [],
    };
  }

  Future<void> loadCachedProfile() async {
    if (_cacheHydrated) return;

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

      _cacheHydrated = true;

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

    final raw = Map<String, dynamic>.from(_myself.toMap());
    final normalized = _normalizeCachedUserMap(raw);

    await _storage.write(
      key: _cachedUserKey,
      value: jsonEncode(normalized),
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
        final raw = Map<String, dynamic>.from(jsonDecode(response.body));
        final normalized = _normalizeCachedUserMap(raw);

        _myself = User.fromMap(normalized);
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

  Future fetchVisitedCount({bool silent = false}) async {
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

      final responses = await Future.wait([
        http.get(
          Uri.parse('$_baseUrl/api/place/visited'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        http.get(
          Uri.parse('$_baseUrl/api/review/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      ]);

      final visitedResponse = responses[0];
      final reviewsResponse = responses[1];

      if (visitedResponse.statusCode < 200 || visitedResponse.statusCode >= 300) {
        throw Exception('Failed to load visited: ${visitedResponse.statusCode}');
      }

      if (reviewsResponse.statusCode < 200 || reviewsResponse.statusCode >= 300) {
        throw Exception('Failed to load reviews: ${reviewsResponse.statusCode}');
      }

      final List visited = List.from(jsonDecode(visitedResponse.body));
      final List reviews = List.from(jsonDecode(reviewsResponse.body));

      final reviewedVisits =
          visited.where((visit) => visit['status'] == 'VISITED').toList();

      visitedPlaces = reviewedVisits.map((visit) {
        final place = Map<String, dynamic>.from(visit['place_id']);
        place['visited_id'] = visit['_id'];
        place['status'] = visit['status'];
        return place;
      }).toList();

      visitedCount = reviewedVisits.length;
      reviewCount = reviews.length;

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
    _cacheHydrated = false;

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

  Future<void> clearVisitedHistory() async {
    try {
      final String? token = await _storage.read(key: 'access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/place/visited/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Failed to clear visited history: ${response.statusCode} ${response.body}',
        );
      }

      visitedPlaces = [];
      visitedCount = 0;

      await _saveCachedVisitedMeta();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }
}