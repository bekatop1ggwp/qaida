import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TemplateProvider extends ChangeNotifier {
  int _templatePageIndex = 3;
  int get templatePageIndex => _templatePageIndex;

  final List<String> _templatePageTitles = [
    'Главная',
    'Категории',
    'Контакты',
    'Профиль',
  ];
  String get getTemplatePageTitle => _templatePageTitles[_templatePageIndex];

  void changeTemplatePage(int index) {
    _templatePageIndex = index;
    notifyListeners();
  }

  Future<bool> isValidImgUrl(String? url) async {
    try {
      if (url == null) return false;
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 404) return false;
      return true;
    } catch(e) {
      return false;
    }
  }
}