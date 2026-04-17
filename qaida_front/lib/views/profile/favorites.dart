import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/favorite_item.dart';
import 'package:qaida/providers/user.provider.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранные')),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4 / 3,
        children: [
          for (var place in context.watch<UserProvider>().myself.favorites)
            FavoriteItem(place: place),
        ],
      ),
    );
  }
}
