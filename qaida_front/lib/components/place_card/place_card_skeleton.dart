import 'package:flutter/material.dart';
import 'package:qaida/components/skeleton_box.dart';

class PlaceCardSkeleton extends StatelessWidget {
  const PlaceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        elevation: 4,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SizedBox(
                width: double.infinity,
                child: SkeletonBox(height: double.infinity, radius: 0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(height: 14, width: 120),
                  SizedBox(height: 6),
                  SkeletonBox(height: 10, width: 90),
                  SizedBox(height: 6),
                  SkeletonBox(height: 10, width: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}