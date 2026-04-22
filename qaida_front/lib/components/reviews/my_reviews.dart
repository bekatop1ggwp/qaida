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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          if (userReviews.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Column(
                children: [
                  Icon(
                    Icons.reviews_outlined,
                    size: 52,
                    color: Color(0xFF8C91A6),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'У вас пока нет оставленных отзывов',
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
            ...userReviews.map(
              (place) => ReviewPlaceListItem(
                place: place,
                showMode: true,
              ),
            ),
        ],
      ),
    );
  }
}