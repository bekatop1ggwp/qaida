import 'package:cached_network_image/cached_network_image.dart';
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
            ? const _ImagePlaceholder()
            : CachedNetworkImage(
                imageUrl: resolvedUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, __) => const _ImagePlaceholder(),
                errorWidget: (_, __, ___) => const _ImagePlaceholder(),
              ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAECEF),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9AA3B2),
      ),
    );
  }
}