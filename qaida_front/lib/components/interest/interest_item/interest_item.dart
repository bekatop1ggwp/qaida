import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';

class InterestItem extends StatelessWidget {
  final int index;

  const InterestItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterestsProvider>();

    final bool isOpen = provider.openItems[index];
    final bool isSelected = provider.selectedItems[index];
    final Map interest = provider.interests[index];
    final String title = (interest['name'] ?? '').toString();
    final List categories = provider.subcategories(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: isOpen
            ? _ExpandedInterestCard(
                title: title,
                isSelected: isSelected,
                categories: categories,
                onArrowTap: () => context.read<InterestsProvider>().changeOpen(index),
                onSelectTap: () => context.read<InterestsProvider>().changeSelect(index),
              )
            : _CollapsedInterestCard(
                title: title,
                isSelected: isSelected,
                onArrowTap: () => context.read<InterestsProvider>().changeOpen(index),
                onSelectTap: () => context.read<InterestsProvider>().changeSelect(index),
              ),
      ),
    );
  }
}

class _CollapsedInterestCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onArrowTap;
  final VoidCallback onSelectTap;

  const _CollapsedInterestCard({
    required this.title,
    required this.isSelected,
    required this.onArrowTap,
    required this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF243C6B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LeftBadge(
          isOpen: false,
          isSelected: isSelected,
          onTap: onArrowTap,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onSelectTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: blue,
                        width: 1.4,
                      ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          blurRadius: 18,
                          offset: Offset(0, 6),
                          color: Color.fromRGBO(0, 0, 0, 0.12),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CheckCircle(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandedInterestCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final List categories;
  final VoidCallback onArrowTap;
  final VoidCallback onSelectTap;

  const _ExpandedInterestCard({
    required this.title,
    required this.isSelected,
    required this.categories,
    required this.onArrowTap,
    required this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF243C6B);

    final List<String> names = categories
        .map((e) => (e is Map ? e['name'] : e).toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final int mid = (names.length / 2).ceil();
    final List<String> left = names.take(mid).toList();
    final List<String> right = names.skip(mid).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LeftBadge(
          isOpen: true,
          isSelected: isSelected,
          onTap: onArrowTap,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              border: isSelected
                  ? null
                  : Border.all(
                      color: blue,
                      width: 1.4,
                    ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        blurRadius: 18,
                        offset: Offset(0, 6),
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: onSelectTap,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CheckCircle(isSelected: isSelected),
                      ],
                    ),
                  ),
                ),
                if (names.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _BulletColumn(items: left)),
                        if (right.isNotEmpty) const SizedBox(width: 18),
                        if (right.isNotEmpty)
                          Expanded(child: _BulletColumn(items: right)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletColumn extends StatelessWidget {
  final List<String> items;

  const _BulletColumn({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF3E4B63);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.2,
                  color: textColor,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LeftBadge extends StatelessWidget {
  final bool isOpen;
  final bool isSelected;
  final VoidCallback onTap;

  const _LeftBadge({
    required this.isOpen,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF243C6B);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: CustomPaint(
          painter: _HexBadgePainter(
            fillColor: isSelected ? Colors.white : Colors.transparent,
            borderColor: blue,
            hasBorder: !isSelected,
            hasShadow: isSelected,
          ),
          child: Center(
            child: isOpen
                ? const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: blue,
                    size: 28,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _MiniLine(),
                      SizedBox(height: 4),
                      _MiniLine(),
                      SizedBox(height: 4),
                      _MiniLine(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 2.6,
      decoration: BoxDecoration(
        color: const Color(0xFF243C6B),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isSelected;

  const _CheckCircle({
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF243C6B);

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? blue : Colors.transparent,
        border: Border.all(
          color: blue,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 15,
        color: isSelected ? Colors.white : blue,
      ),
    );
  }
}

class _HexBadgePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final bool hasBorder;
  final bool hasShadow;

  _HexBadgePainter({
    required this.fillColor,
    required this.borderColor,
    required this.hasBorder,
    required this.hasShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(size.width * 0.32, 0)
      ..lineTo(size.width * 0.68, 0)
      ..lineTo(size.width, size.height * 0.24)
      ..lineTo(size.width, size.height * 0.76)
      ..lineTo(size.width * 0.68, size.height)
      ..lineTo(size.width * 0.32, size.height)
      ..lineTo(0, size.height * 0.76)
      ..lineTo(0, size.height * 0.24)
      ..close();

    if (hasShadow) {
      canvas.drawShadow(path, const Color(0x33000000), 8, false);
    }

    final Paint fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fill);

    if (hasBorder) {
      final Paint stroke = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HexBadgePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.hasBorder != hasBorder ||
        oldDelegate.hasShadow != hasShadow;
  }
}