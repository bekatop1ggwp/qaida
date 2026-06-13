import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/place_card/recommendation_skeleton_grid.dart';
import 'package:qaida/providers/recommendation.provider.dart';

class UnauthorizedHome extends StatefulWidget {
  const UnauthorizedHome({super.key});

  @override
  State<UnauthorizedHome> createState() => _UnauthorizedHomeState();
}

class _UnauthorizedHomeState extends State<UnauthorizedHome> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RecommendationProvider>().getPopularPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecommendationProvider>();
    final places = provider.places;

    if (provider.isLoading && places.isEmpty) {
      return const RecommendationSkeletonGrid();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
      child: GridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        children: [
          for (var place in places)
            PlaceCard(place: Map.from(place)),
        ],
      ),
    );
  }
}