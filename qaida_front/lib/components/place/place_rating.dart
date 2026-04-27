import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PlaceRating extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const PlaceRating({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  String _reviewText(int count) {
    if (count == 1) return '1 отзыв';
    if (count >= 2 && count <= 4) return '$count отзыва';
    return '$count отзывов';
  }

  @override
  Widget build(BuildContext context) {
    final safeRating = rating.clamp(0.0, 5.0);

    return Row(
      children: [
        RatingBarIndicator(
          rating: safeRating,
          itemCount: 5,
          itemSize: 20,
          unratedColor: const Color(0xFFD0D5DD),
          itemBuilder: (_, __) => const Icon(
            Icons.star_rounded,
            color: Color(0xFFFF7A00),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _reviewText(reviewCount),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF344054),
          ),
        ),
      ],
    );
  }
}