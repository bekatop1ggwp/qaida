import 'package:flutter/material.dart';
import 'package:qaida/components/reviews/passed_by_button.dart';
import 'package:qaida/components/reviews/review_place_list_item_description.dart';
import 'package:qaida/components/reviews/review_place_list_item_image.dart';

class ReviewPlaceListItem extends StatelessWidget {
  final Map place;
  final bool showMode;
  final Future<void> Function(Map place)? onDelete;

  const ReviewPlaceListItem({
    super.key,
    required this.place,
    this.showMode = false,
    this.onDelete,
  });

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String id = place['_id']?.toString() ?? '';
    final String? visitedId = place['visited_id']?.toString();
    final String? reviewId = place['review_id']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReviewPlaceListItemImage(url: place['image']?.toString()),
              const SizedBox(width: 10),
              Expanded(
                child: ReviewPlaceListItemDescription(
                  id: id,
                  visitedId: visitedId,
                  title: (place['title'] ?? '').toString(),
                  address: (place['address'] ?? '').toString(),
                  showMode: showMode,
                  reviewScore: _toDouble(place['review_score']),
                  reviewComment: place['review_comment']?.toString(),
                ),
              ),
              if (showMode && reviewId != null && onDelete != null)
                IconButton(
                  tooltip: 'Удалить отзыв',
                  onPressed: () => onDelete!(place),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE94057),
                  ),
                ),
            ],
          ),
          if (!showMode && visitedId != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PassedByButton(
                  placeId: id,
                  visitedId: visitedId,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}