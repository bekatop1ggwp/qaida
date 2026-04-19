import 'package:flutter/material.dart';
import 'package:qaida/components/profile/profile_skeleton_box.dart';

class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 12),
            child: ProfileSkeletonBox(width: 120, height: 20, radius: 8),
          ),
          Expanded(
            child: Row(
              children: const [
                Expanded(
                  child: ProfileSkeletonBox(height: double.infinity, radius: 18),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ProfileSkeletonBox(height: double.infinity, radius: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}