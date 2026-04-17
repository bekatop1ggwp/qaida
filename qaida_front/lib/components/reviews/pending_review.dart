import 'package:flutter/material.dart';
import 'package:qaida/components/reviews/review_info.dart';
import 'package:qaida/components/reviews/review_place_list.dart';

class PendingReview extends StatelessWidget {
  const PendingReview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          ReviewInfo(),
          ReviewPlaceList(),
        ],
      ),
    );
  }
}
