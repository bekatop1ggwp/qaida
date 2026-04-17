import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/place.provider.dart';

class MightBeInteresting extends StatelessWidget {
  const MightBeInteresting({super.key});

  String getPlaceCategory(Map place) => place['category_id'][0];

  @override
  Widget build(BuildContext context) {
    final placeCategory = getPlaceCategory(
      context.watch<PlaceProvider>().place!,
    );
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Вас могут заинтересовать'),
          SizedBox(
            height: 200,
            child: FutureBuilder(
              future: context
                  .read<PlaceProvider>()
                  .getInterestingPlaces(placeCategory),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 1,
                    children: [
                      for (int i = 0; i < snapshot.data?.length && i < 5; i++)
                        PlaceCard(place: Map.from(snapshot.data?[i])),
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
