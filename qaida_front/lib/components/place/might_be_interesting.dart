import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/place_detail_skeleton.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/place.provider.dart';

class MightBeInteresting extends StatefulWidget {
  const MightBeInteresting({super.key});

  @override
  State<MightBeInteresting> createState() => _MightBeInterestingState();
}

class _MightBeInterestingState extends State<MightBeInteresting> {
  late Future<List> _placesFuture;

  String? _extractCategoryId(Map? place) {
    final categories = place?['category_id'];

    if (categories is! List || categories.isEmpty) {
      return null;
    }

    final firstCategory = categories.first;

    if (firstCategory is Map) {
      return firstCategory['_id']?.toString();
    }

    return firstCategory?.toString();
  }

  @override
  void initState() {
    super.initState();

    final placeProvider = context.read<PlaceProvider>();
    final categoryId = _extractCategoryId(placeProvider.place);

    _placesFuture = categoryId == null
        ? Future.value([])
        : placeProvider.getInterestingPlaces(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Вас могут заинтересовать'),
          SizedBox(
            height: 200,
            child: FutureBuilder<List>(
              future: _placesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return MightBeInterestingSkeleton();
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Не удалось загрузить рекомендации'),
                  );
                }

                final places = snapshot.data ?? [];

                if (places.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Нет похожих мест'),
                  );
                }

                return GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  children: [
                    for (int i = 0; i < places.length && i < 5; i++)
                      PlaceCard(place: Map.from(places[i])),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}