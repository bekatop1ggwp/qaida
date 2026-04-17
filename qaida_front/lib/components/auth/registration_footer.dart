import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/auth.provider.dart';

class RegistrationFooter extends StatelessWidget {
  const RegistrationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().changeAuthPage();
            },
            child: const Text('Уже есть аккаунт? Войти'),
          ),
        ],
      ),
    );
  }
}