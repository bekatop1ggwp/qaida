import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/review/place_review_item.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/place.provider.dart';

class PlaceReviewPage extends StatelessWidget {
  const PlaceReviewPage({super.key});

  bool _hasComment(dynamic review) {
    final comment = review['comment']?.toString().trim() ?? '';
    return comment.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<PlaceProvider>().reviews.where(_hasComment).toList();

    return Scaffold(
      appBar: AppBar(),
      body: reviews.isEmpty
          ? const Center(
              child: QText(text: 'Пока нет отзывов'),
            )
          : ListView(
              children: [
                for (var review in reviews)
                  PlaceReviewItem(review: Map.from(review)),
              ],
            ),
    );
  }
}