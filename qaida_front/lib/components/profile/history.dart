import 'package:flutter/material.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/q_text.dart';

class History extends StatelessWidget {
  final List history;

  const History({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 10),
            child: QText(
              text: 'Вы смотрели',
              weight: FontWeight.bold,
              size: 18,
            ),
          ),
          Expanded(
            child: GridView.count(
              scrollDirection: Axis.horizontal,
              childAspectRatio: 3 / 4,
              crossAxisCount: 1,
              primary: false,
              children: [
                for (var place in history) PlaceCard(place: place),
              ],
            ),
          ),
        ],
      ),
    );
  }
}