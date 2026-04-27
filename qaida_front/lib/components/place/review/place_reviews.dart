import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/review/place_review_item.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class PlaceReviews extends StatelessWidget {
  const PlaceReviews({super.key});

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.watch<PlaceProvider>();

    final previewReviews = placeProvider.reviewsPreview.isNotEmpty
        ? placeProvider.reviewsPreview
        : placeProvider.reviews;

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
          child: previewReviews.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: QText(text: 'Пока нет отзывов'),
                )
              : PlaceReviewItem(
                  review: Map.from(previewReviews.first),
                  preview: true,
                ),
        ),
      ],
    );
  }
}