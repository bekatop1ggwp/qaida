import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/full_width_button.dart';
import 'package:qaida/data/user.data.dart';
import 'package:qaida/providers/user.provider.dart';

class ChangeUserData extends StatefulWidget {
  final String? field;

  const ChangeUserData({super.key, this.field});

  @override
  State<StatefulWidget> createState() => _ChangeUserDataState();
}

class _ChangeUserDataState extends State<ChangeUserData> {
  final Map fields = {
    'email': 'Почта',
    'gender': 'Пол',
  };
  final List<String> options = [
    'Мужской',
    'Женский',
    'Не указан',
  ];
  late String selectedValue;
  late User user;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = context.read<UserProvider>().myself;
    selectedValue = user.gender == 'MALE'
        ? 'Мужской'
        : user.gender == 'FEMALE'
            ? 'Женский'
            : 'Не указан';
    controller.text =
        widget.field == null ? '' : user.toMap()[widget.field!] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          widget.field == 'email'
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: widget.field == null ? '' : fields[widget.field],
                    border: const OutlineInputBorder(),
                  ),
                )
              : DropdownButton(
                  value: selectedValue,
                  items: options
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value ?? 'Не указан';
                    });
                  }),
          FullWidthButton(
            margin: const EdgeInsets.only(top: 15.0),
            text: 'Сохранить',
            onPressed: () async {
              widget.field == 'email'
                  ? user.email = controller.text
                  : user.gender = selectedValue == 'Мужской'
                      ? 'MALE'
                      : selectedValue == 'Женский'
                          ? 'FEMALE'
                          : 'BINARY';
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
        ],
      ),
    );
  }
}
