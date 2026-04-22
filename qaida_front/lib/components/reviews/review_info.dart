import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ReviewInfo extends StatelessWidget {
  const ReviewInfo({super.key});

  String _placeWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'место';
    if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'места';
    }
    return 'мест';
  }

  @override
  Widget build(BuildContext context) {
    final processingCount = context.watch<ReviewProvider>().processing.length;
    final visitedCount = context.watch<UserProvider>().visitedCount;
    final total = processingCount + visitedCount;
    final progress =
        total == 0 ? 0.0 : (visitedCount / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B5FEF),
            Color(0xFF7A5AF8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x225B5FEF),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rate_review_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ваш вклад важен',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Оцените места, которые вы недавно посещали, чтобы рекомендации становились точнее.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              processingCount == 0
                  ? 'Все предложения обработаны'
                  : 'Осталось оценить $processingCount ${_placeWord(processingCount)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Оценено: $visitedCount из $total',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}