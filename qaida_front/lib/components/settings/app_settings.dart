import 'package:flutter/material.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/views/interests.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const LightContainer(
      children: [
        ForwardButton(
          text: 'Изменить интересы',
          icon: false,
          page: Interests(),
        ),
        ForwardButton(text: 'Удалить историю просмотра', icon: false),
        ForwardButton(text: 'Удалить историю посещений', icon: false),
      ],
    );
  }
}
