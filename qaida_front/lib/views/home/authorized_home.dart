import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/recommendation.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class AuthorizedHome extends StatefulWidget {
  const AuthorizedHome({super.key});

  @override
  State<AuthorizedHome> createState() => _AuthorizedHomeState();
}

class _AuthorizedHomeState extends State<AuthorizedHome> {
  Future<void>? _recommendationsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = context.read<UserProvider>();
    if (!userProvider.hasMyself) return;

    _recommendationsFuture ??= context
        .read<RecommendationProvider>()
        .getRecommendedPlaces(userProvider.myself.id);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final recommendationProvider = context.watch<RecommendationProvider>();
    final places = recommendationProvider.places;

    if (!userProvider.hasMyself ||
        userProvider.myself.id == null ||
        userProvider.myself.id.toString().isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<void>(
      future: _recommendationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            places.isEmpty) {
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
                      await context
                          .read<RecommendationProvider>()
                          .getRecommendedPlaces(userProvider.myself.id);
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