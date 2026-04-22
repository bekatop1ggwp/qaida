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
    final String? visitedId = place['visited_id']?.toString();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10.0),
      height: 130,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                ReviewPlaceListItemImage(url: place['image']?.toString()),
                ReviewPlaceListItemDescription(
                  id: place['_id'].toString(),
                  visitedId: visitedId,
                  title: (place['title'] ?? '').toString(),
                  address: (place['address'] ?? '').toString(),
                  showMode: showMode,
                  reviewScore: _toDouble(place['review_score']),
                  reviewComment: place['review_comment']?.toString(),
                ),
              ],
            ),
          ),
          if (!showMode && visitedId != null)
            PassedByButton(
              placeId: place['_id'].toString(),
              visitedId: visitedId,
            ),
        ],
      ),
    );
  }
}