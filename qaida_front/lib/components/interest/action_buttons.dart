import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/template.provider.dart';
import 'package:qaida/providers/theme.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  Future<void> handleSend(BuildContext context) async {
    final selectedIds = context.read<InterestsProvider>().getSelectedIds();

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    await context.read<InterestsProvider>().sendInterests(token, selectedIds);
    await context.read<UserProvider>().getMe();
  }

  void navToHome(BuildContext context) {
    Navigator.pop(context);
    context.read<TemplateProvider>().changeTemplatePage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                navToHome(context);
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(
                  context.read<ThemeProvider>().lightBlack,
                ),
              ),
              child: const Text(
                'Пропустить',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            height: 50,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  context.read<ThemeProvider>().lightBlack,
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              onPressed: () async {
                try {
                  await handleSend(context);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Интересы обновлены'),
                      ),
                    );
                    navToHome(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Не удалось сохранить интересы: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Далее',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}