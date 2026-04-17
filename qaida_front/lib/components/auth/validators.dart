import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/auth.provider.dart';

class Validators extends StatelessWidget {
  const Validators({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Column(
      children: [
        Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: authProvider.isPasswordLenCorrect ? Colors.green : Colors.grey,
            ),
            const Text('8 символов (не более 20)'),
          ],
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: authProvider.hasLetterAndDigit ? Colors.green : Colors.grey,
            ),
            const Text('1 буква и 1 цифра'),
          ],
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: authProvider.hasSpecialChar ? Colors.green : Colors.grey,
            ),
            const Text('1 спец. символ (например, #?!\$&@)'),
          ],
        ),
      ],
    );
  }
}