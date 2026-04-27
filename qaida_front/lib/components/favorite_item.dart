import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card_image.dart';
import 'package:qaida/providers/history.provider.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/views/place/place.dart';

class FavoriteItem extends StatelessWidget {
  final Map? place;

  const FavoriteItem({
    super.key,
    this.place,
  });

  @override
  Widget build(BuildContext context) {
    final title = place?['title']?.toString() ?? '';

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
        margin: const EdgeInsets.all(10),
        child: Material(
          elevation: 5,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1F2A44),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}