import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';

class InterestItem extends StatelessWidget {
  final int index;

  const InterestItem({
    super.key,
    required this.index,
  });

  static const Color _blue = Color(0xFF243C6B);
  static const Color _lightBlue = Color(0xFFEAF0FF);
  static const Color _text = Color(0xFF1E2A44);
  static const Color _muted = Color(0xFF667085);

  IconData _iconForTitle(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('еда') || lower.contains('напит')) {
      return Icons.restaurant_rounded;
    }

    if (lower.contains('социал') || lower.contains('общ')) {
      return Icons.groups_rounded;
    }

    if (lower.contains('спокой') || lower.contains('отдых')) {
      return Icons.spa_rounded;
    }

    if (lower.contains('спорт')) {
      return Icons.sports_soccer_rounded;
    }

    if (lower.contains('актив')) {
      return Icons.hiking_rounded;
    }

    if (lower.contains('культур') || lower.contains('музе')) {
      return Icons.museum_rounded;
    }

    return Icons.place_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterestsProvider>();

    final bool isOpen = provider.openItems[index];
    final bool isSelected = provider.selectedItems[index];
    final Map interest = provider.interests[index];

    final String title = (interest['name'] ?? '').toString();
    final List categories = provider.subcategories(index);

    final List<String> categoryNames = categories
        .map((e) => (e is Map ? e['name'] : e).toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _blue : const Color(0xFFE4E7EC),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 7),
              )
            else
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.read<InterestsProvider>().changeSelect(index),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Row(
                    children: [
                      _CategoryIcon(
                        icon: _iconForTitle(title),
                        isSelected: isSelected,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SelectIndicator(isSelected: isSelected),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => context.read<InterestsProvider>().changeOpen(index),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: _blue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _SubcategoryWrap(items: categoryNames),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
                sizeCurve: Curves.easeOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _CategoryIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF243C6B) : const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF243C6B),
        size: 24,
      ),
    );
  }
}

class _SelectIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectIndicator({
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF243C6B) : Colors.transparent,
        border: Border.all(
          color: const Color(0xFF243C6B),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 16,
        color: isSelected ? Colors.white : const Color(0xFF243C6B),
      ),
    );
  }
}

class _SubcategoryWrap extends StatelessWidget {
  final List<String> items;

  const _SubcategoryWrap({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 7,
          runSpacing: 7,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667085),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}