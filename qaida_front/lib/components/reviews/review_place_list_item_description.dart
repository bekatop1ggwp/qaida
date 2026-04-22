import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ReviewPlaceListItemDescription extends StatelessWidget {
  final String id;
  final String? visitedId;
  final String title;
  final String address;
  final bool showMode;
  final double? reviewScore;
  final String? reviewComment;

  const ReviewPlaceListItemDescription({
    super.key,
    required this.id,
    required this.title,
    required this.address,
    required this.visitedId,
    this.showMode = false,
    this.reviewScore,
    this.reviewComment,
  });

  @override
  Widget build(BuildContext context) {
    final hasSavedScore = (reviewScore ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF7D8597),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        if (!showMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Оцените место',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8C91A6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              RatingBar.builder(
                itemCount: 5,
                minRating: 1,
                allowHalfRating: false,
                itemSize: 28,
                unratedColor: const Color(0xFFD7DBE7),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC542),
                ),
                initialRating: 0,
                onRatingUpdate: (double value) async {
                  if (visitedId == null) return;

                  try {
                    await context
                        .read<ReviewProvider>()
                        .sendRating(visitedId!, id, value.toInt());

                    await context
                        .read<UserProvider>()
                        .fetchVisitedCount(silent: true);
                  } catch (e) {
                    if (kDebugMode) print(e);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Не удалось сохранить отзыв'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasSavedScore ? 'Ваш отзыв' : 'Отзыв оставлен',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5B6478),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (hasSavedScore)
                RatingBarIndicator(
                  rating: reviewScore!,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC542),
                  ),
                  unratedColor: const Color(0xFFD7DBE7),
                  itemCount: 5,
                  itemSize: 22,
                ),
              if (!hasSavedScore)
                const Text(
                  'Оценка сохранена',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B6478),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if ((reviewComment ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  reviewComment!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D8597),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}