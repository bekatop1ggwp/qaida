import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/user.provider.dart';

class Visits extends StatelessWidget {
  const Visits({super.key});

  Future<void> _refreshVisits(BuildContext context) async {
    try {
      await context.read<UserProvider>().fetchVisitedCount();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Посещенные места обновлены'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить посещенные места'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visits = context.watch<UserProvider>().visitedPlaces;

    return Scaffold(
      appBar: AppBar(
        title: const QText(text: 'Посещенные места'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshVisits(context),
        child: visits.isEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 180),
                  Icon(
                    Icons.location_on_outlined,
                    size: 54,
                    color: Color(0xFF8C91A6),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'У вас пока нет посещенных мест',
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
                children: [
                  for (var place in visits) PlaceCard(place: place),
                ],
              ),
      ),
    );
  }
}