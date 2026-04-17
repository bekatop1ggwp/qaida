import 'package:flutter/material.dart';
import 'package:qaida/components/interest/action_buttons.dart';
import 'package:qaida/components/header.dart';
import 'package:qaida/components/interest/interest_list.dart';
import 'package:qaida/components/interest/interest_template.dart';

class Interests extends StatelessWidget {
  const Interests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: InterestTemplate(
        children: [
          Header(
            text: 'Выберите интересы',
            fontSize: 40.0,
          ),
          Header(
            text: 'Это поможет нам составлять более точные рекомендации для посещения',
            fontSize: 20.0,
          ),
          InterestList(),
          ActionButtons(),
        ],
      ),
    );
  }
}
