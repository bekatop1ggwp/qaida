import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/review/place_review_item.dart';
import 'package:qaida/providers/place.provider.dart';

class PlaceReviewPage extends StatelessWidget {
  const PlaceReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<PlaceProvider>().reviews;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var review in reviews) PlaceReviewItem(review: review),
        ],
      ),
    );
  }
}