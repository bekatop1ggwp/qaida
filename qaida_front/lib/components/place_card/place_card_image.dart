import 'package:flutter/material.dart';

class PlaceCardImage extends StatelessWidget {
  final Map? place;

  static const String _baseUrl = 'http://192.168.8.6:8080';

  const PlaceCardImage({
    super.key,
    this.place,
  });

  String? _resolveImageUrl(dynamic value) {
    final raw = value?.toString().trim();

    if (raw == null || raw.isEmpty || raw == 'null') {
      return null;
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return '$_baseUrl$raw';
    }

    return '$_baseUrl/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(place?['image']);

    if (imageUrl == null) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _ImagePlaceholder();
      },
      errorBuilder: (_, __, ___) {
        return const _ImagePlaceholder();
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFEAECEF),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9AA3B2),
        size: 28,
      ),
    );
  }
}