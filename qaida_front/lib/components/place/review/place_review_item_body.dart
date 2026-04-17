import 'package:flutter/material.dart';

class PlaceReviewItemBody extends StatelessWidget {
  final String comment;

  const PlaceReviewItemBody({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(Icons.comment_rounded),
            ),
            Flexible(
              child: Text(
                comment,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
