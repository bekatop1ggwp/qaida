import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/place_detail_skeleton.dart';
import 'package:qaida/components/place/review/place_review_item.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class PlaceReviews extends StatefulWidget {
  const PlaceReviews({super.key});

  @override
  State<PlaceReviews> createState() => _PlaceReviewsState();
}

class _PlaceReviewsState extends State<PlaceReviews> {
  late Future<List> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = context.read<PlaceProvider>().getPlaceReview();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return PlaceReviewSkeleton();
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Не удалось загрузить отзывы'),
                );
              }

              final reviews = snapshot.data ?? [];

              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: QText(text: 'Пока нет отзывов'),
                );
              }

              return PlaceReviewItem(
                review: Map.from(reviews[0]),
                preview: true,
              );
            },
          ),
        ),
      ],
    );
  }
}