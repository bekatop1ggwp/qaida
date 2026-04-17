import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/all_button.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/providers/category.provider.dart';
import 'package:qaida/views/categories/category_places.dart';

class CategoryPreview extends StatelessWidget {
  final int index;

  const CategoryPreview({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    return FutureBuilder(
      future: context
          .read<CategoryProvider>()
          .getPlacesByCategories(categories[index]['_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categories[index]['name'],
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
                              places: snapshot.data!,
                              category: categories[index]['name'],
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
                  children: [
                    for (int i = 0; i < 6; i++)
                      PlaceCard(
                        place: Map.from(snapshot.data![i]),
                      ),
                  ],
                ),
              )
            ],
          );
        }
      },
    );
  }
}
