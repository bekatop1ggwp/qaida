import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String text;
  final double fontSize;

  const Header({super.key, required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    );
  }
}