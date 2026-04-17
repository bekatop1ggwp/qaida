import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/template.provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  Future<void> handleSend(BuildContext context) async {
    List<String> interests = context.read<InterestsProvider>().getSelectedIds();

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    await context.read<InterestsProvider>().sendInterests(token!, interests);
  }

  void navToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    context.read<TemplateProvider>().changeTemplatePage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
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
              child: const Text('Пропустить', style: TextStyle(fontSize: 15)),
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
                await handleSend(context);
                navToHome(context);
              },
              child: const Text('Далее', style: TextStyle(fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }
}
