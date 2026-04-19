import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/profile/app_bar/info_button.dart';
import 'package:qaida/providers/user.provider.dart';
import 'package:qaida/views/profile/favorites.dart';
import 'package:qaida/views/profile/reviews.dart';
import 'package:qaida/views/profile/visits.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.hasMyself) {
      return const SizedBox(
        height: 74,
        child: SizedBox.shrink(),
      );
    }

    final user = userProvider.myself;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: InfoButton(
              icon: Icons.bookmark,
              text: 'Избранные',
              count: user.favorites.length,
              page: const Favorites(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoButton(
              icon: Icons.place,
              text: 'Посещенные',
              count: userProvider.visitedCount,
              page: const Visits(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoButton(
              icon: Icons.message,
              text: 'Отзывы',
              count: userProvider.reviewCount,
              page: const Reviews(),
            ),
          ),
        ],
      ),
    );
  }
}