import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/categories/category_preview.dart';
import 'package:qaida/components/categories/category_preview_skeleton.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/place_card/place_card_skeleton.dart';
import 'package:qaida/components/search.dart';
import 'package:qaida/providers/category.provider.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategoriesScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final categories = provider.categories;
    final topPlaces = provider.topPlaces;

    final showInitialSkeleton =
        provider.isScreenLoading && !provider.isInitialDataLoaded;

    return Scaffold(
      appBar: AppBar(title: const Search()),
      body: RefreshIndicator(
        onRefresh: () => context.read<CategoryProvider>().refreshCategoriesScreen(),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Популярные места',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            if (showInitialSkeleton)
              SizedBox(
                height: 180,
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  childAspectRatio: 0.82,
                  primary: false,
                  children: const [
                    PlaceCardSkeleton(),
                    PlaceCardSkeleton(),
                  ],
                ),
              )
            else
              SizedBox(
                height: 180,
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 1,
                  childAspectRatio: 0.82,
                  primary: false,
                  children: [
                    for (var place in topPlaces)
                      PlaceCard(
                        place: (() {
                          final mapped = Map<String, dynamic>.from(place);
                          mapped['_id'] = mapped['place_id'] ?? mapped['_id'];
                          return mapped;
                        })(),
                      ),
                  ],
                ),
              ),
            if (showInitialSkeleton)
              ...List.generate(
                3,
                (_) => const CategoryPreviewSkeleton(),
              )
            else
              ...categories.map((category) {
                final categoryId = category['_id'].toString();

                if (!provider.hasPlacesForCategory(categoryId)) {
                  return const CategoryPreviewSkeleton();
                }

                return CategoryPreview(
                  categoryName: category['name'],
                  places: provider.getPlacesForCategory(categoryId),
                );
              }),
          ],
        ),
      ),
    );
  }
}