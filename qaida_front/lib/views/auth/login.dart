import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/full_width_button.dart';
import 'package:qaida/components/auth/password.dart';
import 'package:qaida/providers/auth.provider.dart';
import 'package:qaida/providers/login.provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Такого пользователя не существует';
    } else {
      return null;
    }
  }

  Future<void> handleLogin(
    BuildContext context,
    AuthProvider authProvider,
    LoginProvider loginProvider,
  ) async {
    if (!authProvider.loginFormKey.currentState!.validate()) return;

    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    NavigatorState navigator = Navigator.of(context);

    final tokens = await context.read<LoginProvider>().login(
          loginProvider.emailController.text,
          loginProvider.passwordController.text,
        );

    if (tokens == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Не удалось войти')),
      );
      return;
    }

    const storage = FlutterSecureStorage();
    await storage.write(key: 'access_token', value: tokens['access_token']);
    await storage.write(key: 'refresh_token', value: tokens['refresh_token']);

    authProvider.changeAuthStatus();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final loginProvider = context.watch<LoginProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: authProvider.loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Введите данные',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: loginProvider.emailController,
                validator: (String? email) {
                  return emailValidator(email);
                },
                decoration: const InputDecoration(
                  labelText: 'Эл. почта',
                ),
              ),
              Password(
                controller: loginProvider.passwordController,
              ),
              FullWidthButton(
                text: 'Войти',
                margin: const EdgeInsets.only(top: 20.0),
                onPressed: () async {
                  await handleLogin(context, authProvider, loginProvider);
                },
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().changeAuthPage();
                        },
                        child: const Text('Еще нет аккаунта? Регистрация'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
