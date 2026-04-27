import 'package:flutter/material.dart';

class InterestTemplate extends StatelessWidget {
  final List<Widget> children;

  const InterestTemplate({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F3F6),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}