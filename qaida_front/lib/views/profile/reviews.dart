import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/q_icon.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/components/reviews/my_reviews.dart';
import 'package:qaida/components/reviews/pending_review.dart';
import 'package:qaida/providers/review.provider.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  late Future<void> _processingFuture;

  @override
  void initState() {
    super.initState();
    _processingFuture = _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ReviewProvider>().getProcessingPlaces();
  }

  void _retry() {
    setState(() {
      _processingFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F3F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F3F6),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const QIcon(icon: Icons.arrow_back_ios),
          ),
          title: const QText(text: 'Мои отзывы'),
          bottom: const TabBar(
            tabs: [
              Tab(child: QText(text: 'Ожидают отзыва')),
              Tab(child: QText(text: 'Мои отызывы')),
            ],
          ),
        ),
        body: FutureBuilder<void>(
          future: _processingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Не удалось загрузить отзывы'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            return const TabBarView(
              children: [
                PendingReview(),
                MyReviews(),
              ],
            );
          },
        ),
      ),
    );
  }
}