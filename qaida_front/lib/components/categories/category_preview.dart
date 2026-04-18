import 'package:flutter/material.dart';
import 'package:qaida/components/all_button.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/views/categories/category_places.dart';

class CategoryPreview extends StatelessWidget {
  final String categoryName;
  final List places;

  const CategoryPreview({
    super.key,
    required this.categoryName,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    final previewPlaces = places.take(6).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                ),
              ),
              AllButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryPlaces(
                        places: places,
                        category: categoryName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 350,
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            primary: false,
            children: [
              for (final place in previewPlaces)
                PlaceCard(place: Map.from(place)),
            ],
          ),
        ),
      ],
    );
  }
}