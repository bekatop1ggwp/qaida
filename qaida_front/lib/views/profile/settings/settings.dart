import 'package:flutter/material.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/components/settings/account_settings.dart';
import 'package:qaida/components/settings/app_settings.dart';
import 'package:qaida/components/settings/settings_template.dart';
import 'package:qaida/components/settings/user_data.dart';
import 'package:qaida/components/settings/username.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsTemplate(
      children: [
        Username(),
        Padding(
          padding: EdgeInsets.all(7.0),
          child: QText(text: 'Данные пользователя', size: 17),
        ),
        UserData(),
        Padding(
          padding: EdgeInsets.all(7.0),
          child: QText(text: 'Приложение', size: 17),
        ),
        AppSettings(),
        Padding(
          padding: EdgeInsets.all(7.0),
          child: QText(text: 'Аккаунт', size: 17),
        ),
        AccountSettings(),
      ],
    );
  }
}