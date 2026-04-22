import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/reviews/review_place_list_item.dart';
import 'package:qaida/providers/review.provider.dart';

class MyReviews extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const MyReviews({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final userReviews = context.watch<ReviewProvider>().myReviews;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: userReviews.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Center(
                  child: Text('У вас пока нет оставленных отзывов'),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                for (var place in userReviews)
                  ReviewPlaceListItem(
                    place: place,
                    showMode: true,
                  ),
              ],
            ),
    );
  }
}