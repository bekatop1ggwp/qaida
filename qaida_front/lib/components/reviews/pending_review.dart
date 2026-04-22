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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const ReviewInfo(),
          if (pendingReviews.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 52,
                    color: Color(0xFF8C91A6),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Нет мест, ожидающих отзыва',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...pendingReviews.map(
              (place) => ReviewPlaceListItem(place: place),
            ),
        ],
      ),
    );
  }
}