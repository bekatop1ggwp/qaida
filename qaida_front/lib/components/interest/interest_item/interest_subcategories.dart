import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/interest/interest_item/subcategories_container.dart';
import 'package:qaida/providers/interests.provider.dart';

class InterestSubcategories extends StatelessWidget {
  final int index;

  const InterestSubcategories({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestsProvider>();
    return SubcategoriesContainer(
      index: index,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              interestProvider.interests[index]['name'],
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                interestProvider.selectedItems[index] ?
                Icons.check_circle : Icons.check_circle_outline
              ),
            ),
          ],
        ),
        StaggeredGrid.count(
          crossAxisCount: 2,
          children: [
            for (var i = 0; i < interestProvider.subcategories(index).length; i++)
              Text('• ${interestProvider.subcategories(index)[i]['name']}'),
          ],
        ),
      ],
    );
  }

}