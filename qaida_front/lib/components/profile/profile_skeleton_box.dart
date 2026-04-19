import 'package:flutter/material.dart';

class ProfileSkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ProfileSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<ProfileSkeletonBox> createState() => _ProfileSkeletonBoxState();
}

class _ProfileSkeletonBoxState extends State<ProfileSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = 0.82 + (_controller.value * 0.18);

        return Opacity(
          opacity: value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF0),
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}