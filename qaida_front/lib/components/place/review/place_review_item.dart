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

  int _parseScore(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value.clamp(0, 5);
    }

    if (value is double) {
      return value.round().clamp(0, 5);
    }

    if (value is num) {
      return value.round().clamp(0, 5);
    }

    if (value is Map && value['\$numberDecimal'] != null) {
      final parsed = double.tryParse(value['\$numberDecimal'].toString()) ?? 0;
      return parsed.round().clamp(0, 5);
    }

    final parsed = double.tryParse(value.toString()) ?? 0;
    return parsed.round().clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final score = _parseScore(review['score']);

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
            score: score,
            date: review['created_at']?.toString() ?? '',
            user: Map.from(review['user_id'] ?? {}),
          ),
          PlaceReviewItemBody(
            comment: review['comment']?.toString() ?? '',
          ),
          PlaceReviewItemFooter(
            id: review['_id'],
            votes: List.from(review['votes'] ?? []),
            preview: preview,
          ),
        ],
      ),
    );
  }
}