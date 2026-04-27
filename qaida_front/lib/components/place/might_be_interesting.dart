import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/place.provider.dart';

class MightBeInteresting extends StatelessWidget {
  const MightBeInteresting({super.key});

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().interestingPlaces;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Вас могут заинтересовать'),
          SizedBox(
            height: 200,
            child: places.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Нет похожих мест'),
                  )
                : GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 1,
                    children: [
                      for (int i = 0; i < places.length && i < 5; i++)
                        PlaceCard(place: Map.from(places[i])),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}