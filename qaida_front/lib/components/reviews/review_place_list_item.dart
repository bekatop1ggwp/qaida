import 'package:flutter/material.dart';
import 'package:qaida/components/reviews/passed_by_button.dart';
import 'package:qaida/components/reviews/review_place_list_item_description.dart';
import 'package:qaida/components/reviews/review_place_list_item_image.dart';

class ReviewPlaceListItem extends StatelessWidget {
  final Map place;
  final bool showMode;

  const ReviewPlaceListItem({
    super.key,
    required this.place,
    this.showMode = false,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReviewPlaceListItemImage(url: place['image']?.toString()),
              const SizedBox(width: 12),
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
            ],
          ),
          if (!showMode && visitedId != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: PassedByButton(
                placeId: id,
                visitedId: visitedId,
              ),
            ),
          ],
        ],
      ),
    );
  }
}