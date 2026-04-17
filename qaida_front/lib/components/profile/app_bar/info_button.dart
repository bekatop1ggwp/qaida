import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/q_icon.dart';
import 'package:qaida/components/q_text.dart';
import 'package:qaida/providers/theme.provider.dart';

class InfoButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final int count;
  final Widget? page;

  const InfoButton({
    super.key,
    required this.icon,
    required this.text,
    required this.count,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: context.watch<ThemeProvider>().darkWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: () {
            if (page == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QIcon(icon: icon),
              QText(text: text, weight: FontWeight.bold),
              QText(text: '$count места', size: 10),
            ],
          ),
        ),
      ),
    );
  }
}
