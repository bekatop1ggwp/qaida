import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/template.provider.dart';

class ReviewPlaceListItemImage extends StatelessWidget {
  final String url;

  const ReviewPlaceListItemImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: FutureBuilder(
        future: context.read<TemplateProvider>().isValidImgUrl(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data!
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                  )
                : const Center(child: Icon(Icons.image_outlined));
          }
        },
      ),
    );
  }
}
