import 'package:qaida/core/api_config.dart';

class RecommendationApi {
  static const String recommendationBaseUrl = ApiConfig.recommendationBaseUrl;

  static String get recommendUrl => '$recommendationBaseUrl/recommend';
}