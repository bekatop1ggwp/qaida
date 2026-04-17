import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/history.provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 22, right: 22, bottom: 20),
      margin: const EdgeInsets.only(top: 30.0),
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10.0, left: 10.0),
            child: QText(
              text: 'Вы смотрели',
              weight: FontWeight.bold,
              size: 18,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: context.read<HistoryProvider>().getHistory(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.count(
                    scrollDirection: Axis.horizontal,
                    childAspectRatio: 3/4,
                    crossAxisCount: 1,
                    children: [
                      for (var place in snapshot.data!) PlaceCard(place: place),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
