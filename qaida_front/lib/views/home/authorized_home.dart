import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/recommendation.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class AuthorizedHome extends StatelessWidget {
  const AuthorizedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().myself;
    final places = context.watch<RecommendationProvider>().places;

    if (user.id == null || user.id.toString().isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: context.read<RecommendationProvider>().getRecommendedPlaces(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && places.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else if (places.isEmpty) {
          return const Center(
            child: Text(
              'Рекомендаций пока нет',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    'Рекомендуем',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 27,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<RecommendationProvider>().clearRecommendations();
                      await context.read<RecommendationProvider>().getRecommendedPlaces(user.id);
                    },
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        for (var place in places)
                          PlaceCard(place: place, encoded: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}