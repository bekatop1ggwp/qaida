import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/place.provider.dart';
import 'package:qaida/views/place/place_review_page.dart';

class PlaceReviewItemFooter extends StatefulWidget {
  final List votes;
  final String id;
  final bool preview;

  const PlaceReviewItemFooter({
    super.key,
    required this.votes,
    required this.id,
    required this.preview,
  });

  @override
  State<StatefulWidget> createState() => _PlaceReviewItemFooterState();
}

class _PlaceReviewItemFooterState extends State<PlaceReviewItemFooter> {
  int positiveCount = 0;
  int negativeCount = 0;

  @override
  void initState() {
    super.initState();
    positiveCount =
        widget.votes.where((vote) => vote['type'] == 'POSITIVE').length;
    negativeCount =
        widget.votes.where((vote) => vote['type'] == 'NEGATIVE').length;
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.read<PlaceProvider>();
    return Column(
      children: [
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await placeProvider.voteReview(widget.id, 'POSITIVE');
                      setState(() {
                        positiveCount++;
                      });
                    },
                    icon: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.thumb_up_alt_rounded),
                        ),
                        Text(positiveCount.toString()),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await placeProvider.voteReview(widget.id, 'NEGATIVE');
                      setState(() {
                        negativeCount++;
                      });
                    },
                    icon: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.thumb_down_alt_rounded),
                        ),
                        Text(negativeCount.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.preview)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlaceReviewPage()),
                  );
                },
                icon: const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Все отзывы'),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
