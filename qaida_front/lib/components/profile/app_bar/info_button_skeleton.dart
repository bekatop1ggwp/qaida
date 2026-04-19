import 'package:flutter/material.dart';
import 'package:qaida/components/profile/profile_skeleton_box.dart';

class InfoButtonSkeleton extends StatelessWidget {
  const InfoButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      constraints: const BoxConstraints(minHeight: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ProfileSkeletonBox(width: 18, height: 18, radius: 6),
          SizedBox(height: 8),
          ProfileSkeletonBox(width: 66, height: 12, radius: 6),
          SizedBox(height: 6),
          ProfileSkeletonBox(width: 42, height: 10, radius: 6),
        ],
      ),
    );
  }
}