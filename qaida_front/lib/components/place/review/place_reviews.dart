import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/review/place_review_item.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class PlaceReviews extends StatelessWidget {
  const PlaceReviews({super.key});

  bool _hasComment(dynamic review) {
    final comment = review['comment']?.toString().trim() ?? '';
    return comment.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.watch<PlaceProvider>();

    final allReviews = placeProvider.reviewsPreview.isNotEmpty
        ? placeProvider.reviewsPreview
        : placeProvider.reviews;

    final reviewsWithText = allReviews.where(_hasComment).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: QText(
            text: 'Оценки и отзывы',
            weight: FontWeight.bold,
          ),
        ),
        Container(
          color: context.watch<ThemeProvider>().lightWhite,
          child: reviewsWithText.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: QText(text: 'Пока нет отзывов'),
                )
              : PlaceReviewItem(
                  review: Map.from(reviewsWithText.first),
                  preview: true,
                ),
        ),
      ],
    );
  }
}