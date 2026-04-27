import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/place_image.dart';
import 'package:qaida/components/place/place_rating.dart';
import 'package:qaida/providers/auth.provider.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class PlaceHeader extends StatelessWidget {
  const PlaceHeader({super.key});

  String? _extractId(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      return value['_id']?.toString();
    }

    return value.toString();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is Map && value['\$numberDecimal'] != null) {
      return double.tryParse(value['\$numberDecimal'].toString()) ?? 0;
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  double _calculateAppRating(Map? place) {
    final scores = List.from(place?['score'] ?? []);

    if (scores.isEmpty) {
      return 0;
    }

    final total = scores.fold<double>(
      0,
      (sum, score) => sum + _toDouble(score),
    );

    return total / scores.length;
  }

  @override
  Widget build(BuildContext context) {
    final place = context.watch<PlaceProvider>().place;
    final isAuthorized = context.watch<AuthProvider>().isAuthorized;
    final userProvider = context.watch<UserProvider>();

    final canUseUser = isAuthorized && userProvider.hasMyself;

    final placeId = _extractId(place);
    final scores = List.from(place?['score'] ?? []);
    final rating = _calculateAppRating(place);
    final reviewCount = scores.length;

    bool isLiked = false;

    if (canUseUser && placeId != null) {
      isLiked = userProvider.myself.favorites.any(
        (favPlace) => _extractId(favPlace) == placeId,
      );
    }

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place?['title']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          PlaceRating(
                            rating: rating,
                            reviewCount: reviewCount,
                          ),
                        ],
                      ),
                    ),
                    if (canUseUser)
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
                        icon: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked
                              ? const Color(0xFFE94057)
                              : const Color(0xFF98A2B3),
                          size: 28,
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