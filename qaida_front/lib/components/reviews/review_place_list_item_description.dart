import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';

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
          RatingBar.builder(
            itemBuilder: (BuildContext context, _) => const Icon(
              Icons.star_rounded,
              color: Colors.yellow,
            ),
            initialRating: showMode ? 4 : 0,
            ignoreGestures: showMode,
            onRatingUpdate: (double value) async {
              if (showMode) return;
              try {
                await context
                    .read<ReviewProvider>()
                    .sendRating(visitedId, id, value.toInt());
              } catch (e) {
                if (kDebugMode) print(e);
              }
            },
          ),
        ],
      ),
    );
  }
}
