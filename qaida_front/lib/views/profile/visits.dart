import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/user.provider.dart';

class Visits extends StatelessWidget {
  const Visits({super.key});

  @override
  Widget build(BuildContext context) {
    final visits = context.watch<UserProvider>().visitedPlaces;
    return Scaffold(
      appBar: AppBar(
        title: const QText(text: 'Посещенные места'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          for (var place in visits) PlaceCard(place: place)
        ],
      ),
    );
  }
}
