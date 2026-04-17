import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/theme.provider.dart';

class QIcon extends StatelessWidget {
  final IconData icon;

  const QIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: context.watch<ThemeProvider>().lightBlack);
  }
}