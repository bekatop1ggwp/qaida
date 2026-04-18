import 'package:flutter/material.dart';

class PlaceCardImage extends StatelessWidget {
  final Map? place;

  const PlaceCardImage({
    super.key,
    this.place,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = place != null &&
        place?['image'] != null &&
        (place?['image'] as String).startsWith('/');

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: hasNetworkImage
              ? NetworkImage('http://192.168.8.6:8080${place!['image']}')
              : const AssetImage('assets/R.jpg') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}