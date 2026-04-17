import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qaida/components/q_text.dart';

class PlaceReviewItemHeader extends StatelessWidget {
  final int score;
  final String date;
  final Map user;

  const PlaceReviewItemHeader({
    super.key,
    required this.score,
    required this.date,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(Icons.person),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingBar.builder(
              itemBuilder: (_, __) => const Icon(
                Icons.star_rounded,
                color: Colors.orange,
              ),
              itemSize: 20,
              ignoreGestures: true,
              initialRating: score.toDouble(),
              onRatingUpdate: (value) {},
            ),
            QText(
              text:
                  '${user['name'] ?? user['email']} • ${date.substring(0, 10)}',
            ),
          ],
        ),
      ],
    );
  }
}
