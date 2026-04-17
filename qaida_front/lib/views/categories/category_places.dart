import 'package:flutter/material.dart';
import 'package:qaida/components/place_card/place_card.dart';

class CategoryPlaces extends StatelessWidget {
  final List places;
  final String category;

  const CategoryPlaces({
    super.key,
    required this.places,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(10.0),
        crossAxisCount: 2,
        children: [
          for (var place in places) PlaceCard(place: place),
        ],
      ),
    );
  }
}
