import 'package:flutter/material.dart';
import 'package:qaida/views/auth/auth.dart';
import 'package:qaida/components/full_width_button.dart';

class Unauthorized extends StatelessWidget {
  const Unauthorized({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const Icon(Icons.person_outlined, size: 150.0,),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 15.0,
                  ),
                  child: const Text(
                    'Войти в существующий аккаунт',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FullWidthButton(
            text: 'Вход в аккаунт',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Auth(),
                ),
              );
            },
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}