import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/place.provider.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key});

  static const String _baseUrl = 'http://192.168.8.6:8080';

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
    final place = context.watch<PlaceProvider>().place;
    final imageUrl = _resolveImageUrl(place?['image']);

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: imageUrl == null
          ? const _PlaceImagePlaceholder()
          : Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const _PlaceImagePlaceholder(
                  isLoading: true,
                );
              },
              errorBuilder: (_, __, ___) {
                return const _PlaceImagePlaceholder();
              },
            ),
    );
  }
}

class _PlaceImagePlaceholder extends StatelessWidget {
  final bool isLoading;

  const _PlaceImagePlaceholder({
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAECEF),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.image_outlined,
                color: Color(0xFF9AA3B2),
                size: 42,
              ),
      ),
    );
  }
}