import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';

class SubcategoriesContainer extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const SubcategoriesContainer({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestsProvider>();
    return Material(
      elevation: interestProvider.selectedItems[index] ? 5.0 : 0.0,
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: interestProvider.selectedItems[index] ?
          Colors.white : Color(int.parse('4DD3D3D3', radix: 16)),
          border: Border.all(
            color: interestProvider.selectedItems[index] ?
            Colors.white : Colors.black,
            width: 2.0,
          ),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}