import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  int _authPageIndex = 0;
  int get authPageIndex => _authPageIndex;

  bool _isAuthorized = false;
  bool get isAuthorized => _isAuthorized;

  String _authPageTitle = 'Войти';
  String get authPageTitle => _authPageTitle;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool isPasswordLenCorrect = false;
  bool hasLetterAndDigit = false;
  bool hasSpecialChar = false;

  void changeAuthPage() {
    _authPageIndex = _authPageIndex == 0 ? 1 : 0;
    _authPageTitle = _authPageTitle == 'Войти' ? 'Зарегистрироваться' : 'Войти';
    notifyListeners();
  }

  void changeAuthStatus() {
    _isAuthorized = _isAuthorized == false ? true : false;
    notifyListeners();
  }

  void changePasswordVisibility() {
    _isPasswordVisible = _isPasswordVisible == false ? true : false;
    notifyListeners();
  }

  void changeValidationState(String password) {
    if (
      password.length > 7
      && password.length <= 20
    ) {
      isPasswordLenCorrect = true;
    } else {
      isPasswordLenCorrect = false;
    }

    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    if (hasDigit && hasLetter) {
      hasLetterAndDigit = true;
    } else {
      hasLetterAndDigit = false;
    }

    if (RegExp(r'[#!?$&@%]').hasMatch(password)) {
      hasSpecialChar = true;
    } else {
      hasSpecialChar = false;
    }
    notifyListeners();
  }

  Future register(String email, String password) async {
    await http.post(
      Uri.parse('http://192.168.8.6:8080/api/auth'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: Uri(
        queryParameters: {
          'email': email,
          'password': password,
        },
      ).query,
    );
  }
}