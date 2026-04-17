import 'package:flutter/material.dart';

class InterestTemplate extends StatelessWidget {
  final List<Widget> children;

  const InterestTemplate({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      decoration: BoxDecoration(
        color: Color(int.parse('4DD3D3D3', radix: 16)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

}