import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place/might_be_interesting.dart';
import 'package:qaida/components/place/place_detail_skeleton.dart';
import 'package:qaida/components/place/place_header.dart';
import 'package:qaida/components/place/place_map.dart';
import 'package:qaida/components/place/review/place_reviews.dart';
import 'package:qaida/components/search.dart';
import 'package:qaida/providers/place.provider.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  late Future<void> _placeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _placeDetailsFuture = context.read<PlaceProvider>().getPlaceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Search(),
      ),
      body: FutureBuilder<void>(
        future: _placeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PlacePageSkeleton();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Не удалось загрузить место'),
            );
          }

          final place = context.watch<PlaceProvider>().place;

          if (place == null || place['error'] != null) {
            return const Center(
              child: Text('Нет такого места'),
            );
          }

          return ListView(
            children: [
              PlaceHeader(),
              PlaceReviews(),
              MightBeInteresting(),
              PlaceMap(),
            ],
          );
        },
      ),
    );
  }
}