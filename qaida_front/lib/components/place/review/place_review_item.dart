import 'package:flutter/material.dart';
import 'package:qaida/components/place/review/place_review_item_body.dart';
import 'package:qaida/components/place/review/place_review_item_footer.dart';
import 'package:qaida/components/place/review/place_review_item_header.dart';

class PlaceReviewItem extends StatelessWidget {
  final Map review;
  final bool preview;

  const PlaceReviewItem({
    super.key,
    required this.review,
    this.preview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: 280,
      margin: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          PlaceReviewItemHeader(
            score: int.parse(review['score']['\$numberDecimal']),
            date: review['created_at'],
            user: review['user_id'],
          ),
          PlaceReviewItemBody(comment: review['comment']),
          PlaceReviewItemFooter(
            id: review['_id'],
            votes: review['votes'],
            preview: preview,
          ),
        ],
      ),
    );
  }
}
