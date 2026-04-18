import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/q_icon.dart';
import 'package:qaida/providers/theme.provider.dart';

class InfoButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final int count;
  final Widget? page;

  const InfoButton({
    super.key,
    required this.icon,
    required this.text,
    required this.count,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: context.watch<ThemeProvider>().darkWhite,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          if (page == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              QIcon(icon: icon),
              const SizedBox(height: 6),
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF243B63),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count места',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF243B63),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}