import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/reviews/review_info.dart';
import 'package:qaida/components/reviews/review_place_list_item.dart';
import 'package:qaida/providers/review.provider.dart';

class PendingReview extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const PendingReview({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final pendingReviews = context.watch<ReviewProvider>().processing;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: pendingReviews.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                ReviewInfo(),
                SizedBox(height: 120),
                Center(
                  child: Text('Нет мест, ожидающих отзыва'),
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const ReviewInfo(),
                for (var place in pendingReviews)
                  ReviewPlaceListItem(
                    place: place,
                  ),
              ],
            ),
    );
  }
}