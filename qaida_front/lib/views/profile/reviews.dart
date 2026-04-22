import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/q_icon.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/components/reviews/my_reviews.dart';
import 'package:qaida/components/reviews/pending_review.dart';
import 'package:qaida/providers/review.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  late Future<void> _processingFuture;
  bool _isCreatingDemo = false;

  @override
  void initState() {
    super.initState();
    _processingFuture = _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ReviewProvider>().refreshAll();
    await context.read<UserProvider>().fetchVisitedCount();
  }

  Future<void> _refresh() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createDemoSuggestions() async {
    if (_isCreatingDemo) return;

    setState(() {
      _isCreatingDemo = true;
    });

    try {
      await context.read<ReviewProvider>().createDemoSuggestions(count: 5);
      await context.read<UserProvider>().fetchVisitedCount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo-предложения созданы'),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка demo: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingDemo = false;
        });
      }
    }
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
          actions: [
            if (kDebugMode)
              IconButton(
                tooltip: 'Создать demo-предложения',
                onPressed: _isCreatingDemo ? null : _createDemoSuggestions,
                icon: _isCreatingDemo
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(child: QText(text: 'Ожидают отзыва')),
              Tab(child: QText(text: 'Мои отзывы')),
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

            return TabBarView(
              children: [
                PendingReview(onRefresh: _refresh),
                MyReviews(onRefresh: _refresh),
              ],
            );
          },
        ),
      ),
    );
  }
}