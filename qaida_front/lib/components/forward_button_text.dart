import 'package:flutter/material.dart';

class Unlabeled extends StatelessWidget {
  final String text;

  const Unlabeled({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1E3050),
        fontSize: 18.0,
      ),
    );
  }
}

class Labeled extends StatelessWidget {
  final String label;
  final String text;

  const Labeled({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xAA1E3050),
            fontSize: 12.0,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1E3050),
            fontSize: 17.0,
          ),
        ),
      ],
    );
  }
}