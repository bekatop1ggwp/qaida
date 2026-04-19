import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/place_card/recommendation_skeleton_grid.dart';
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
                await context
                    .read<RecommendationProvider>()
                    .getRecommendedPlaces(userProvider.myself.id);
              },
              child: Builder(
                builder: (context) {
                  if (recommendationProvider.isLoading && places.isEmpty) {
                    return const RecommendationSkeletonGrid();
                  }

                  if (!recommendationProvider.isLoading && places.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 220),
                        Center(
                          child: Text(
                            'Рекомендаций пока нет',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    );
                  }

                  return Stack(
                    children: [
                      GridView.count(
                        physics: const AlwaysScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                        children: [
                          for (var place in places)
                            PlaceCard(place: place, encoded: true),
                        ],
                      ),
                      if (recommendationProvider.isLoading && places.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.white.withOpacity(0.35),
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 16),
                              child: const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2.6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}