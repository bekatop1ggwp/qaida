import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/providers/theme.provider.dart';

class LightContainer extends StatelessWidget {
  final List<ForwardButton> children;
  final EdgeInsetsGeometry margin;

  const LightContainer({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().lightWhite,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++)
            ...[
              children[i],
              if (i != children.length-1)
                const Divider(height: 0, color: Color(0xFF1E3050),),
            ]
        ],
      ),
    );
  }
}