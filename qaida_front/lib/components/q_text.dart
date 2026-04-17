import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class QText extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? weight;

  const QText({super.key, required this.text, this.size, this.weight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.watch<ThemeProvider>().lightBlack,
        overflow: TextOverflow.ellipsis,
        fontWeight: weight,
        fontSize: size,
      ),
    );
  }
}
