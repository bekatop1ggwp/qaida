import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qaida/core/api_config.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future login(String email, String password) async {
    try {
      http.Response response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/api/auth/login'),
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
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch(e) {
      return null;
    }
  }
}