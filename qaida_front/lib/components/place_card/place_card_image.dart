import 'package:flutter/material.dart';

class PlaceCardImage extends StatelessWidget {
  final Map? place;

  const PlaceCardImage({super.key, this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: place == null ||
                place?['image'] == null ||
                !(place?['image'] as String).startsWith('/')
            ? const DecorationImage(
                image: AssetImage('assets/R.jpg'),
                fit: BoxFit.cover,
              )
            : DecorationImage(
                image: NetworkImage('http://192.168.8.6:8080${place!['image']}'),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
