import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card_image.dart';
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
      final names = <String>[];
      for (var category in categories) {
        if (category is Map && category['name'] != null) {
          names.add(category['name'].toString());
        }
      }
      return names.join(', ');
    } catch (e) {
      return '';
    }
  }

  String decode(String ogStr) {
    return ogStr;
  }

  Map<String, dynamic>? get recommendationReason {
    final reason = place?['recommendation_reason'];
    if (reason is Map) {
      return Map<String, dynamic>.from(reason);
    }
    return null;
  }

  Widget _reasonRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showRecommendationReason(BuildContext context) {
    final reason = recommendationReason;
    if (reason == null) return;

    final type = reason['type'];
    final accuracy = reason['accuracy'];
    final contentMatch = reason['contentMatch'];
    final behaviorSignal = reason['behaviorSignal'];
    final similarUsersCount = reason['similarUsersCount'];
    final rating = reason['rating'];
    final visitsCount = reason['visitsCount'];
    final text = reason['text']?.toString() ?? 'Место рекомендовано системой.';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Почему рекомендовано?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
                const SizedBox(height: 6),
                if (type == 'personalized') ...[
                  if (accuracy is num)
                    _reasonRow('Итоговая релевантность', '${accuracy.round()}%'),
                  if (contentMatch is num)
                    _reasonRow('Совпадение с интересами', '${contentMatch.round()}%'),
                  if (behaviorSignal is num)
                    _reasonRow('Поведенческий сигнал', '${behaviorSignal.round()}%'),
                  if (similarUsersCount is num)
                    _reasonRow('Похожие пользователи посещали', '${similarUsersCount.round()}'),
                  if (rating is num)
                    _reasonRow('Рейтинг места', '${rating.toStringAsFixed(1)} / 5'),
                ] else ...[
                  if (visitsCount is num && visitsCount > 0)
                    _reasonRow('Посещений пользователями', '${visitsCount.round()}'),
                  if (rating is num)
                    _reasonRow('Рейтинг места', '${rating.toStringAsFixed(1)} / 5'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = place == null ? 'Хан шатыр' : decode(place!['title'] ?? '');
    final subtitle = place == null
        ? 'Торгово-развлекательный центр'
        : decode(categories(place!['category_id'] ?? []));
    final address =
        place == null ? 'Проспект Туран, 37' : decode(place!['address'] ?? '');
    final reason = recommendationReason;

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
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: PlaceCardImage(place: place),
                    ),
                    if (reason != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white.withOpacity(0.92),
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _showRecommendationReason(context),
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.question_mark,
                                size: 18,
                                color: Color(0xFF6A4FB6),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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