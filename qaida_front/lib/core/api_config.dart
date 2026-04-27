class ApiConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.8.6:8080',
  );

  static const String recommendationBaseUrl = String.fromEnvironment(
    'RECOMMENDATION_API_URL',
    defaultValue: 'http://192.168.8.6:8001',
  );

  static String get geolocationSocketUrl => '$apiBaseUrl/geolocation';

  static String imageById(String imageId) {
    return '$apiBaseUrl/api/image/$imageId';
  }

  static String? resolveFileUrl(dynamic value) {
    final raw = value?.toString().trim();

    if (raw == null || raw.isEmpty || raw == 'null') {
      return null;
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return '$apiBaseUrl$raw';
    }

    return '$apiBaseUrl/$raw';
  }
}