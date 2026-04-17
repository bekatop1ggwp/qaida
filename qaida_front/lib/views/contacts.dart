import 'package:flutter/material.dart';
import 'package:qaida/components/all_button.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/search.dart';

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Search()),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Друзья',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                AllButton(),
              ],
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < 5; i++)
                const ForwardButton(
                  text: 'Примерный Пример',
                  leading: Icon(
                    Icons.person_pin,
                    color: Color(0xFF1E3050),
                    size: 50.0,
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Группы',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                AllButton(),
              ],
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < 3; i++)
                const ForwardButton(
                  text: 'Примерный Пример',
                  leading: Icon(
                    Icons.square_rounded,
                    color: Color(0xFF1E3050),
                    size: 50.0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
