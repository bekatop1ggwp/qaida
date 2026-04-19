import 'package:flutter/material.dart';
import 'package:qaida/components/profile/profile_skeleton_box.dart';

class AppBarButtonSkeleton extends StatelessWidget {
  const AppBarButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: ProfileSkeletonBox(
        width: 220,
        height: 28,
        radius: 8,
      ),
    );
  }
}