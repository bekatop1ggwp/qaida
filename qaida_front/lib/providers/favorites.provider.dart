import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FavoritesProvider extends ChangeNotifier {
  List favoriteIds = [];

  Future getFavorites() async {
    try {
      await http.get(
        Uri.parse(''),
      );
    } catch(e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }
}