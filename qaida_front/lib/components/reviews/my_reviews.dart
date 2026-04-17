import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/reviews/review_place_list_item.dart';
import 'package:qaida/providers/user.provider.dart';

class MyReviews extends StatelessWidget {
  const MyReviews({super.key});

  @override
  Widget build(BuildContext context) {
    final userReviews = context.watch<UserProvider>().visitedPlaces;
    return ListView(
      children: [
        for (var place in userReviews)
          ReviewPlaceListItem(
            place: place,
            showMode: true,
          ),
      ],
    );
  }
}
