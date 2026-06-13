import 'package:flutter/material.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/views/categories/category_places.dart';

class CategoryPreview extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final List places;

  const CategoryPreview({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryPlaces(
                        rubricId: categoryId,
                        category: categoryName,
                        initialPlaces: places,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6F4BB2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(
                      color: Color(0xFF6F4BB2),
                      width: 1,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Все',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                    ),
                  ],
                ),
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
              for (final place in places)
                PlaceCard(place: Map.from(place)),
            ],
          ),
        ),
      ],
    );
  }
}