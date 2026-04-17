import 'package:flutter/material.dart';

class UnauthorizedHome extends StatelessWidget {
  const UnauthorizedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Ввойдите для того, чтобы посмотреть рекомендации'),
    );
  }
}