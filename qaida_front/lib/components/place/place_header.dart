import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/place_image.dart';
import 'package:qaida/components/place/place_rating.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class PlaceHeader extends StatelessWidget {
  const PlaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final place = context.watch<PlaceProvider>().place;
    final isLiked = context.watch<UserProvider>().myself.favorites.any(
          (favPlace) => favPlace['_id'] == place?['_id'],
        );
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          const PlaceImage(),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place?['title'] ?? ''),
                        PlaceRating(
                          rating: double.parse(
                              place?['score_2gis']['\$numberDecimal']),
                          reviewCount: List.from(place?['score']).length,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await context.read<UserProvider>().changeFavPlaces(
                                place!,
                                !isLiked,
                              );
                        } catch (_) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Ошибка. Попробуйте позже'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.thumb_up_rounded),
                      style: ButtonStyle(
                        iconColor: WidgetStateProperty.all(
                          isLiked ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
