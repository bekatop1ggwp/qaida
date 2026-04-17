import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';

class InterestIcon extends StatelessWidget {
  final int index;

  const InterestIcon({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final interestProvider = context.watch<InterestsProvider>();
    return CustomPaint(
      painter: HexagonPainter(interestProvider.selectedItems[index]),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: interestProvider.openItems[index] ?
          const Icon(Icons.keyboard_arrow_up, size: 50,) :
          const Icon(Icons.menu, size: 50,),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  bool isSelected;

  HexagonPainter(this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.white : Colors.black
      ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 4)
      ..lineTo(size.width, size.height * 3 / 4)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 3 / 4)
      ..lineTo(0, size.height / 4)
      ..close();
    double elevation = isSelected ? 5.0 : 0.0;
    canvas.drawShadow(path, Colors.black, elevation, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}