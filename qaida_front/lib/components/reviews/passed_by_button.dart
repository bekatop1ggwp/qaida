import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class PassedByButton extends StatelessWidget {
  final String placeId;
  final String visitedId;

  const PassedByButton({
    super.key,
    required this.placeId,
    required this.visitedId,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        try {
          await context.read<ReviewProvider>().skip(visitedId, placeId);
          await context.read<UserProvider>().fetchVisitedCount(silent: true);
        } catch (e) {
          if (kDebugMode) print(e);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Не удалось обновить статус места'),
              ),
            );
          }
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF8A3D),
        side: const BorderSide(
          color: Color(0xFFFFC39A),
        ),
        backgroundColor: const Color(0xFFFFF7F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      icon: const Icon(Icons.directions_walk_rounded, size: 18),
      label: const Text(
        'Проходил мимо',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}