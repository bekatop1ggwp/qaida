import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/might_be_interesting.dart';
import 'package:qaida/components/place/place_header.dart';
import 'package:qaida/components/place/place_map.dart';
import 'package:qaida/components/place/review/place_reviews.dart';
import 'package:qaida/components/search.dart';
import 'package:qaida/providers/place.provider.dart';

class Place extends StatelessWidget {
  const Place({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F3F6),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
          ),
          title: const Search(),
        ),
        body: FutureBuilder(
          future: context.read<PlaceProvider>().getPlaceById(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else {
              final place = context.watch<PlaceProvider>().place;
              if (place == null || place['error'] != null) {
                return const Center(child: Text('Нет такого места'));
              }
              return ListView(
                children: const [
                  PlaceHeader(),
                  PlaceReviews(),
                  MightBeInteresting(),
                  PlaceMap(),
                ],
              );
            }
          },
        ),
      );
    } catch(e) {
      rethrow;
    }
  }
}
