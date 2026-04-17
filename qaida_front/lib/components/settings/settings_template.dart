import 'package:flutter/material.dart';

class SettingsTemplate extends StatelessWidget {
  final List<Widget> children;

  const SettingsTemplate({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F3F6),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1E3050),
          ),
        ),
        title: const Text(
          'Мои данные',
          style: TextStyle(
            color: Color(0xFF1E3050),
          ),
        ),
      ),
      body: ListView(
        children: children,
      ),
    );
  }
}