import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/providers/user.provider.dart';
import 'package:qaida/views/profile/settings/change_user_data.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().myself;
    return LightContainer(
      children: [
        ForwardButton(
          label: 'Почта',
          text: user.email,
          page: const ChangeUserData(field: 'email'),
        ),
        ForwardButton(
          label: 'Пол',
          text: user.gender == 'MALE'
              ? 'Мужской'
              : (user.gender == 'FEMALE' ? 'Женский' : 'Не указан'),
          page: const ChangeUserData(field: 'gender'),
        ),
      ],
    );
  }
}
