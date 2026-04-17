import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/providers/template.provider.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key});

  @override
  Widget build(BuildContext context) {
    final place = context.watch<PlaceProvider>().place;
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: FutureBuilder(
        future: context.read<TemplateProvider>().isValidImgUrl(place?['image']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return place?['image'] == null || !snapshot.data!
              ? const Center(
                  child: Icon(Icons.image_search),
                )
              : Image.network(
                  place?['image'],
                  fit: BoxFit.cover,
                );
        },
      ),
    );
  }
}
