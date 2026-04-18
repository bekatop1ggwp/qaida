import 'package:flutter/material.dart';
import 'package:qaida/components/place_card/place_card_skeleton.dart';
import 'package:qaida/components/skeleton_box.dart';

class CategoryPreviewSkeleton extends StatelessWidget {
  const CategoryPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBox(height: 16, width: 120),
              SkeletonBox(height: 32, width: 56, radius: 18),
            ],
          ),
        ),
        SizedBox(
          height: 350,
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            primary: false,
            children: const [
              PlaceCardSkeleton(),
              PlaceCardSkeleton(),
              PlaceCardSkeleton(),
              PlaceCardSkeleton(),
              PlaceCardSkeleton(),
              PlaceCardSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}