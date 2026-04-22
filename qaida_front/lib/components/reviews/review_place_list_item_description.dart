import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ReviewPlaceListItemDescription extends StatelessWidget {
  final String id;
  final String visitedId;
  final String title;
  final String address;
  final bool showMode;

  const ReviewPlaceListItemDescription({
    super.key,
    required this.id,
    required this.title,
    required this.address,
    required this.visitedId,
    this.showMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, overflow: TextOverflow.ellipsis),
          Text(address),
          if (!showMode)
            RatingBar.builder(
              itemBuilder: (BuildContext context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.yellow,
              ),
              initialRating: 0,
              onRatingUpdate: (double value) async {
                try {
                  await context
                      .read<ReviewProvider>()
                      .sendRating(visitedId, id, value.toInt());

                  await context
                      .read<UserProvider>()
                      .fetchVisitedCount(silent: true);
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
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Отзыв оставлен',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}