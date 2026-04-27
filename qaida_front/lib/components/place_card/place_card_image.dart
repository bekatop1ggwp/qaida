import 'package:flutter/material.dart';
import 'package:qaida/core/api_config.dart';

class PlaceCardImage extends StatelessWidget {
  final Map? place;

  const PlaceCardImage({
    super.key,
    this.place,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.resolveFileUrl(place?['image']);

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