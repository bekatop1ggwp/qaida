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
    return GestureDetector(
      onTap: () async {
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
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Color(0xFFFF993A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
          ),
        ),
        child: const RotatedBox(
          quarterTurns: 1,
          child: Text(
            'Проходил мимо',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}