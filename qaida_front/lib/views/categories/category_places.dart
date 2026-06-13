import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/place_card/place_card.dart';
import 'package:qaida/components/place_card/place_card_skeleton.dart';
import 'package:qaida/providers/category.provider.dart';

class CategoryPlaces extends StatefulWidget {
  final String rubricId;
  final String category;
  final List initialPlaces;

  const CategoryPlaces({
    super.key,
    required this.rubricId,
    required this.category,
    required this.initialPlaces,
  });

  @override
  State<CategoryPlaces> createState() => _CategoryPlacesState();
}

class _CategoryPlacesState extends State<CategoryPlaces> {
  final ScrollController _scrollController = ScrollController();

  final List _places = [];

  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  static const int _limit = 10;

  @override
  void initState() {
    super.initState();

    _places.addAll(widget.initialPlaces);

    _loadFirstPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  String _placeUniqueKey(dynamic place) {
    final title = place['title']?.toString().trim().toLowerCase() ?? '';
    final address = place['address']?.toString().trim().toLowerCase() ?? '';

    return '$title|$address';
  }

  void _addUniquePlaces(List newPlaces, {bool replace = false}) {
    if (replace) {
      _places.clear();
    }

    final existingKeys = _places.map(_placeUniqueKey).toSet();

    for (final place in newPlaces) {
      final key = _placeUniqueKey(place);

      if (key.trim() == '|' || existingKeys.contains(key)) {
        continue;
      }

      _places.add(place);
      existingKeys.add(key);
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = _places.isEmpty;
    });

    try {
      final result = await context.read<CategoryProvider>().getCategoryPlacesPage(
            rubricId: widget.rubricId,
            page: 1,
            limit: _limit,
          );

      setState(() {
        _page = result['page'] ?? 1;
        _totalPages = result['totalPages'] ?? 1;
        _addUniquePlaces(
          List.from(result['places'] ?? []),
          replace: true,
        );
      });
    } catch (e) {
      debugPrint('CategoryPlaces first page error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _page >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _page + 1;

      final result = await context.read<CategoryProvider>().getCategoryPlacesPage(
            rubricId: widget.rubricId,
            page: nextPage,
            limit: _limit,
          );

      setState(() {
        _page = result['page'] ?? nextPage;
        _totalPages = result['totalPages'] ?? _totalPages;
        _addUniquePlaces(
          List.from(result['places'] ?? []),
        );
      });
    } catch (e) {
      debugPrint('CategoryPlaces load more error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    _totalPages = 1;
    await _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _places.length + (_isLoadingMore ? 2 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _isLoading
            ? GridView.count(
                padding: const EdgeInsets.all(10.0),
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                children: const [
                  PlaceCardSkeleton(),
                  PlaceCardSkeleton(),
                  PlaceCardSkeleton(),
                  PlaceCardSkeleton(),
                ],
              )
            : GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= _places.length) {
                    return const PlaceCardSkeleton();
                  }

                  return PlaceCard(place: Map.from(_places[index]));
                },
              ),
      ),
    );
  }
}