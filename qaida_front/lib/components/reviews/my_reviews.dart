import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/reviews/review_place_list_item.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class MyReviews extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const MyReviews({
    super.key,
    required this.onRefresh,
  });

  Future<void> _deleteReview(BuildContext context, Map place) async {
    final reviewId = place['review_id']?.toString();

    if (reviewId == null || reviewId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить отзыв?'),
          content: const Text(
            'Будет удален только отзыв. История посещений, место, избранное и профиль не будут затронуты.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Удалить',
                style: TextStyle(
                  color: Color(0xFFE94057),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await context.read<ReviewProvider>().deleteMyReview(reviewId);
      await context.read<UserProvider>().fetchVisitedCount(silent: true);
      await onRefresh();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отзыв удален'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось удалить отзыв: $e'),
        ),
      );
    }
  }

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
                onDelete: (place) => _deleteReview(context, place),
              ),
            ),
        ],
      ),
    );
  }
}