import 'package:flutter/material.dart';
import 'package:qaida/core/api_config.dart';

class ReviewPlaceListItemImage extends StatelessWidget {
  final String? url;

  const ReviewPlaceListItemImage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConfig.resolveFileUrl(url);

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