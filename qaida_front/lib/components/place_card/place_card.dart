import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card_image.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/history.provider.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/views/place/place.dart';

class PlaceCard extends StatelessWidget {
  final Map? place;
  final bool encoded;

  const PlaceCard({
    super.key,
    this.place,
    this.encoded = false,
  });

  String categories(List categories) {
    try {
      String res = '';
      for (var category in categories) {
        res = '$res, ${category['name']}';
      }
      return res.substring(2);
    } catch (e) {
      return '';
    }
  }

  String decode(String ogStr) {
    if (!encoded) return ogStr;
    final bytes = ogStr.codeUnits;
    return utf8.decode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final title = place == null ? 'Хан шатыр' : decode(place!['title'] ?? '');
    final subtitle = place == null
        ? 'Торгово-развлекательный центр'
        : decode(categories(place!['category_id'] ?? []));
    final address =
        place == null ? 'Проспект Туран, 37' : decode(place!['address'] ?? '');

    return GestureDetector(
      onTap: () async {
        if (place == null) return;

        context.read<PlaceProvider>().setId(place!['_id']);
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await context.read<HistoryProvider>().addHistory(place?['_id']);

        try {
          navigator.push(
            MaterialPageRoute(builder: (_) => const Place()),
          );
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Не удалось открыть страницу')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Material(
          elevation: 4,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: PlaceCardImage(place: place),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}