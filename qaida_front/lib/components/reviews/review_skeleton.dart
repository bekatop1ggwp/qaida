import 'package:flutter/material.dart';

class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      children: const [
        _SkeletonSummaryCard(),
        _SkeletonReviewCard(),
        _SkeletonReviewCard(),
        _SkeletonReviewCard(),
      ],
    );
  }
}

class _SkeletonSummaryCard extends StatelessWidget {
  const _SkeletonSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFE9ECF3),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 180, height: 22, radius: 8),
          SizedBox(height: 12),
          _SkeletonBox(width: double.infinity, height: 14, radius: 8),
          SizedBox(height: 8),
          _SkeletonBox(width: 240, height: 14, radius: 8),
          SizedBox(height: 16),
          _SkeletonBox(width: 170, height: 34, radius: 999),
          SizedBox(height: 16),
          _SkeletonBox(width: double.infinity, height: 10, radius: 999),
          SizedBox(height: 12),
          _SkeletonBox(width: 110, height: 14, radius: 8),
        ],
      ),
    );
  }
}

class _SkeletonReviewCard extends StatelessWidget {
  const _SkeletonReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 74, height: 74, radius: 16),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 170, height: 18, radius: 8),
                    SizedBox(height: 8),
                    _SkeletonBox(width: 130, height: 14, radius: 8),
                    SizedBox(height: 12),
                    _SkeletonBox(width: 95, height: 12, radius: 8),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _SkeletonStar(),
                        SizedBox(width: 4),
                        _SkeletonStar(),
                        SizedBox(width: 4),
                        _SkeletonStar(),
                        SizedBox(width: 4),
                        _SkeletonStar(),
                        SizedBox(width: 4),
                        _SkeletonStar(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _SkeletonBox(width: 140, height: 34, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonStar extends StatelessWidget {
  const _SkeletonStar();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBox(width: 20, height: 20, radius: 999);
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.85),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          width: width == double.infinity ? null : width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFE3E7EF),
              const Color(0xFFF0F3F8),
              value,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
      onEnd: () {},
    );
  }
}