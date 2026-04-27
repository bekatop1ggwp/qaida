import 'package:flutter/material.dart';
import 'package:qaida/components/place_card/place_card_skeleton.dart';
import 'package:qaida/components/skeleton_box.dart';

class PlacePageSkeleton extends StatelessWidget {
  const PlacePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _PlaceHeaderSkeleton(),
        PlaceReviewSkeleton(),
        MightBeInterestingSkeleton(),
        Padding(
          padding: EdgeInsets.all(10),
          child: SkeletonBox(height: 220, radius: 12),
        ),
      ],
    );
  }
}

class _PlaceHeaderSkeleton extends StatelessWidget {
  const _PlaceHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(
              width: double.infinity,
              height: 300,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 1, radius: 0),
                  SizedBox(height: 12),
                  SkeletonBox(width: 180, height: 16),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceReviewSkeleton extends StatelessWidget {
  const PlaceReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        height: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 28, height: 28, radius: 14),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 110, height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(width: 170, height: 12),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: 230, height: 12),
            Spacer(),
            SkeletonBox(width: double.infinity, height: 1, radius: 0),
            SizedBox(height: 14),
            SkeletonBox(width: 120, height: 14),
          ],
        ),
      ),
    );
  }
}

class MightBeInterestingSkeleton extends StatelessWidget {
  const MightBeInterestingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 10),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (_, __) {
          return const SizedBox(
            width: 165,
            child: PlaceCardSkeleton(),
          );
        },
      ),
    );
  }
}