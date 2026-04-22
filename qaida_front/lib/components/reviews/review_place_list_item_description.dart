import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ReviewPlaceListItemDescription extends StatelessWidget {
  final String id;
  final String? visitedId;
  final String title;
  final String address;
  final bool showMode;
  final double? reviewScore;
  final String? reviewComment;

  const ReviewPlaceListItemDescription({
    super.key,
    required this.id,
    required this.title,
    required this.address,
    required this.visitedId,
    this.showMode = false,
    this.reviewScore,
    this.reviewComment,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, overflow: TextOverflow.ellipsis),
            Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (!showMode)
              RatingBar.builder(
                itemBuilder: (BuildContext context, _) => const Icon(
                  Icons.star_rounded,
                  color: Colors.yellow,
                ),
                initialRating: 0,
                minRating: 1,
                allowHalfRating: false,
                onRatingUpdate: (double value) async {
                  if (visitedId == null) return;

                  try {
                    await context
                        .read<ReviewProvider>()
                        .sendRating(visitedId!, id, value.toInt());

                    await context.read<UserProvider>().fetchVisitedCount();
                  } catch (e) {
                    if (kDebugMode) print(e);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Не удалось сохранить отзыв'),
                        ),
                      );
                    }
                  }
                },
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: reviewScore ?? 0,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star_rounded,
                      color: Colors.yellow,
                    ),
                    itemCount: 5,
                    itemSize: 20,
                  ),
                  if ((reviewComment ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reviewComment!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}