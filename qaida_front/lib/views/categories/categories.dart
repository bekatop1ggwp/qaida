import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/categories/category_preview.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/search.dart';
import 'package:qaida/providers/category.provider.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final categoryProvider = context.read<CategoryProvider>();
    return FutureBuilder(
      future: Future.wait([
        categoryProvider.getCategories(),
        categoryProvider.getTopPlaces(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          final topPlaces = context.watch<CategoryProvider>().topPlaces;
          return Scaffold(
            appBar: AppBar(title: const Search()),
            body: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Популярные места',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 1,
                    children: [
                      for (var place in topPlaces)
                        PlaceCard(place: Map.from(place)),
                    ],
                  ),
                ),
                for (int i = 0; i < categories.length; i++)
                  CategoryPreview(index: i),
              ],
            ),
          );
        }
      },
    );
  }
}
