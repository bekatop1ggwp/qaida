import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/auth.provider.dart';
import 'package:qaida/providers/theme.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return LightContainer(
      children: [
        ForwardButton(
          leading: const Icon(
            Icons.exit_to_app,
            color: Color(0xFF1E3050),
          ),
          text: 'Выйти из аккаунта',
          icon: false,
          onPressed: () {
            const storage = FlutterSecureStorage();
            storage.delete(key: 'access_token');
            context.read<AuthProvider>().changeAuthStatus();
            Navigator.pop(context);
          },
        ),
        ForwardButton(
          leading: const Icon(
            Icons.restore_from_trash,
            color: Color(0xFF1E3050),
          ),
          text: 'Деактивировать/удалить аккаунт',
          icon: false,
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              messenger.showMaterialBanner(
                MaterialBanner(
                  backgroundColor: context.read<ThemeProvider>().lightWhite,
                  content: const QText(
                    text: 'Деактивировать аккаунт?',
                    size: 20,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        messenger.clearMaterialBanners();
                      },
                      child: const QText(text: 'Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final userProvider = context.read<UserProvider>();
                        final navigator = Navigator.of(context);
                        messenger.clearMaterialBanners();
                        const storage = FlutterSecureStorage();
                        await storage.deleteAll();
                        authProvider.changeAuthStatus();
                        await userProvider.changeUser(
                          userProvider.myself,
                          true,
                        );
                        navigator.pop();
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(
                          context.read<ThemeProvider>().lightBlack,
                        ),
                      ),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
            } catch (_) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Ошибка. Попробуйте позже')),
              );
            }
          },
        ),
      ],
    );
  }
}
