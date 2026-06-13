import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/core/api_config.dart';
import 'package:qaida/providers/place.provider.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key});

  @override
  Widget build(BuildContext context) {
    final place = context.watch<PlaceProvider>().place;
    final imageUrl = ApiConfig.resolveFileUrl(place?['image']);

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: imageUrl == null
          ? const _PlaceImagePlaceholder()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) => const _PlaceImagePlaceholder(
                isLoading: true,
              ),
              errorWidget: (_, __, ___) => const _PlaceImagePlaceholder(),
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