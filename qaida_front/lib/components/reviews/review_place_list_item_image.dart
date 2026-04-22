import 'package:flutter/material.dart';

class ReviewPlaceListItemImage extends StatelessWidget {
  final String? url;

  const ReviewPlaceListItemImage({super.key, required this.url});

  String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return 'http://192.168.8.6:8080$raw';
    }

    return 'http://192.168.8.6:8080/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(url);

    return Container(
      width: 120,
      height: 80,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: resolvedUrl == null
            ? const ColoredBox(
                color: Color(0xFFEAEAEA),
                child: Center(
                  child: Icon(Icons.image_outlined),
                ),
              )
            : Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFEAEAEA),
                  child: Center(
                    child: Icon(Icons.image_outlined),
                  ),
                ),
              ),
      ),
    );
  }
}