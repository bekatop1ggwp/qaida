import 'package:flutter/material.dart';

class PlaceRating extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const PlaceRating({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            Icons.star_rounded,
            color: Color(i + 1 <= rating.round() ? 0xFFFF7A00 : 0xFFFBBE86),
          ),
        Text('$reviewCount отзывов'),
      ],
    );
  }
}
