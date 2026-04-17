import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/interest/interest_item/interest_icon.dart';
import 'package:qaida/components/interest/interest_item/interest_subcategories.dart';
import 'package:qaida/components/interest/interest_item/interest_text.dart';
import 'package:qaida/providers/interests.provider.dart';

class InterestItem extends StatelessWidget {
  final int index;

  const InterestItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestsProvider>();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: interestProvider.openItems[index]
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              context.read<InterestsProvider>().changeOpen(index);
            },
            child: InterestIcon(index: index),
          ),
          GestureDetector(
            onTap: () {
              context.read<InterestsProvider>().changeSelect(index);
            },
            child: interestProvider.openItems[index]
                ? InterestSubcategories(index: index)
                : InterestText(index: index),
          ),
        ],
      ),
    );
  }
}
