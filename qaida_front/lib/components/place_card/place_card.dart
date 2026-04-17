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

  const PlaceCard({super.key, this.place, this.encoded = false});

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
    List<int> bytes = ogStr.codeUnits;
    return utf8.decode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (place == null) return;
        context.read<PlaceProvider>().setId(place!['_id']);
        final NavigatorState navigator = Navigator.of(context);
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
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
        height: 90,
        margin: const EdgeInsets.all(10.0),
        child: Material(
          elevation: 5,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlaceCardImage(place: place),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QText(
                      text:
                          place == null ? 'Хан шатыр' : decode(place!['title']),
                      weight: FontWeight.bold,
                    ),
                    QText(
                      text: place == null
                          ? 'Торгово-развлекательный центр'
                          : decode(categories(place!['category_id'])),
                      size: 10,
                    ),
                    QText(
                      text: place == null
                          ? 'Проспект Туран, 37'
                          : decode(place!['address'] ?? ''),
                      size: 10,
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
