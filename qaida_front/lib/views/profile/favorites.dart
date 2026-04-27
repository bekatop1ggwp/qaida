import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/favorite_item.dart';
import 'package:qaida/providers/user.provider.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  Future<void> _refreshFavorites(BuildContext context) async {
    try {
      await context.read<UserProvider>().getMe();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Избранные обновлены'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить избранные'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final favorites =
        userProvider.hasMyself ? userProvider.myself.favorites : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Избранные')),
      body: RefreshIndicator(
        onRefresh: () => _refreshFavorites(context),
        child: favorites.isEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 180),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 54,
                    color: Color(0xFF8C91A6),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'У вас пока нет избранных мест',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                crossAxisCount: 2,
                childAspectRatio: 4 / 3,
                children: [
                  for (var place in favorites) FavoriteItem(place: place),
                ],
              ),
      ),
    );
  }
}