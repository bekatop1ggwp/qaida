import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card_image.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/views/place/place.dart';

import '../providers/history.provider.dart';
import '../providers/place.provider.dart';

class FavoriteItem extends StatelessWidget {
  final Map? place;

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

  const FavoriteItem({super.key, this.place});

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
                      place == null ? 'Хан шатыр' : place!['title'],
                      weight: FontWeight.bold,
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