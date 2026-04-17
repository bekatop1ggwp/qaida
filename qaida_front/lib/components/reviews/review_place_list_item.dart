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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10.0),
      height: 130,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                ReviewPlaceListItemImage(url: place['image']),
                ReviewPlaceListItemDescription(
                  id: place['_id'],
                  visitedId: place['visited_id'],
                  title: place['title'],
                  address: place['address'],
                  showMode: showMode,
                ),
              ],
            ),
          ),
          if (!showMode)
            PassedByButton(
              placeId: place['_id'],
              visitedId: place['visited_id'],
            ),
        ],
      ),
    );
  }
}
