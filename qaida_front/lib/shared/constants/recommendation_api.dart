class RecommendationApi {
  static const String recommendationBaseUrl = String.fromEnvironment(
    'RECOMMENDATION_API_URL',
    defaultValue: 'http://192.168.8.6:8001',
  );

  static String get recommendUrl => '$recommendationBaseUrl/recommend';
}