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
    final user = context.watch<UserProvider>().myself;
    return Row(
      children: [
        InfoButton(
          icon: Icons.bookmark,
          text: 'Избранные',
          count: user.favorites.length,
          page: const Favorites(),
        ),
        InfoButton(
          icon: Icons.place,
          text: 'Посетил(-а)',
          count: context.watch<UserProvider>().visitedCount,
          page: const Visits(),
        ),
        InfoButton(
          icon: Icons.message,
          text: 'Отзывы',
          count: context.watch<UserProvider>().reviewCount,
          page: const Reviews(),
        ),
      ],
    );
  }
}
