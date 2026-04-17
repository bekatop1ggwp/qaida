import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ReviewInfo extends StatelessWidget {
  const ReviewInfo({super.key});

  String placeEnding(int count) {
    if (count == 1) return 'o';
    return [2, 3, 4].contains(count) ? 'a' : '';
  }

  @override
  Widget build(BuildContext context) {
    int processingCount = context.watch<ReviewProvider>().processing.length;
    int visitedCount = context.watch<UserProvider>().visitedCount;
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Image.asset(
              'assets/reviews.png',
              fit: BoxFit.cover,
              color: Colors.black45,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Отличная работа!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Оставляя отзыв вы подтверждаете, что посещали данное место. Осталось оценить $processingCount мест${placeEnding(processingCount)}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                LinearProgressIndicator(
                  value: visitedCount / (processingCount + visitedCount),
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                  minHeight: 12.0,
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
