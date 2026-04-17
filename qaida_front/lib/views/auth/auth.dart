import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/views/auth/login.dart';
import 'package:qaida/views/auth/registration.dart';
import 'package:qaida/providers/auth.provider.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.authPageTitle),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: authProvider.authPageIndex,
        children: const <Widget>[
          Login(),
          Registration(),
        ],
      ),
    );
  }
}