import 'package:flutter/material.dart';

class ReviewPlaceListItemImage extends StatelessWidget {
  final String? url;

  const ReviewPlaceListItemImage({
    super.key,
    required this.url,
  });

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 74,
        height: 74,
        child: resolvedUrl == null
            ? Container(
                color: const Color(0xFFEAECEF),
                child: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF9AA3B2),
                ),
              )
            : Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEAECEF),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF9AA3B2),
                  ),
                ),
              ),
      ),
    );
  }
}