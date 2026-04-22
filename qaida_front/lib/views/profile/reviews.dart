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
    await context.read<UserProvider>().fetchVisitedCount(silent: true);
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
      await context.read<UserProvider>().fetchVisitedCount(silent: true);

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
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F7FB),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const QIcon(icon: Icons.arrow_back_ios),
          ),
          title: const QText(text: 'Мои отзывы'),
          actions: [
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
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: const Color(0xFF2D3142),
            unselectedLabelColor: const Color(0xFF8C91A6),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tabs: const [
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: QText(text: 'Ожидают отзыва'),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: QText(text: 'Мои отзывы'),
                ),
              ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: Color(0xFF8C91A6),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Не удалось загрузить отзывы',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B5FEF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
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