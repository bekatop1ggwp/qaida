import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/auth.provider.dart';

class Password extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const Password({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return TextFormField(
      controller: controller,
      obscureText: authProvider.isPasswordVisible,
      onChanged: onChanged,
      validator: (password) {
        if (password == null || password.isEmpty) {
          return 'Пароль введен не правильно';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: 'Пароль',
        suffixIcon: IconButton(
          onPressed: () {
            context.read<AuthProvider>().changePasswordVisibility();
          },
          icon: Icon(
            authProvider.isPasswordVisible ?
            Icons.visibility_off_outlined :
            Icons.remove_red_eye_outlined,
          ),
        ),
      ),
    );
  }
}