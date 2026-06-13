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

  Future<void> _openReviewDialog(BuildContext context, int rating) async {
    if (visitedId == null) return;

    final commentController = TextEditingController();

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Оставить отзыв'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBarIndicator(
                rating: rating.toDouble(),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC542),
                ),
                unratedColor: const Color(0xFFC3CAD9),
                itemCount: 5,
                itemSize: 28,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: commentController,
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Напишите отзыв, если хотите',
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4BB2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (shouldSend != true) return;

    try {
      await context.read<ReviewProvider>().sendRating(
            visitedId!,
            id,
            rating,
            comment: commentController.text,
          );

      await context.read<UserProvider>().fetchVisitedCount(silent: true);
    } catch (e) {
      if (kDebugMode) print(e);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить отзыв'),
          ),
        );
      }
    } finally {
      commentController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSavedScore = (reviewScore ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3142),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF7D8597),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
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
              const SizedBox(height: 4),
              RatingBar.builder(
                itemCount: 5,
                minRating: 1,
                allowHalfRating: false,
                itemSize: 26,
                unratedColor: const Color(0xFFC3CAD9),
                itemPadding: const EdgeInsets.only(right: 2),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC542),
                ),
                initialRating: 0,
                onRatingUpdate: (double value) {
                  _openReviewDialog(context, value.toInt());
                },
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                  unratedColor: const Color(0xFFC3CAD9),
                  itemCount: 5,
                  itemSize: 20,
                ),
              if ((reviewComment ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  reviewComment!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D8597),
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}