import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/full_width_button.dart';
import 'package:qaida/providers/user.provider.dart';

class ChangeUsername extends StatelessWidget {
  final TextEditingController surname = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController fatherName = TextEditingController();

  ChangeUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().myself;
    surname.text = user.surname ?? '';
    name.text = user.name ?? '';
    fatherName.text = user.fatherName ?? '';
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: surname,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Фамилия',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Имя',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: fatherName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Отчество',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FullWidthButton(
              text: 'Сохранить',
              onPressed: () async {
                user.surname = surname.text;
                user.name = name.text;
                user.fatherName = fatherName.text;
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await context.read<UserProvider>().changeUser(user, false);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Данные изменены')),
                  );
                } catch (_) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Ошибка. Попробуйте позже')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
