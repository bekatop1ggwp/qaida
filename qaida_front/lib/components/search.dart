import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: SearchBar(
        padding: WidgetStatePropertyAll(EdgeInsets.only(left: 20.0)),
        elevation: WidgetStatePropertyAll(0),
        leading: Icon(Icons.search),
        backgroundColor: WidgetStatePropertyAll(Color(0xFFF6F7FB)),
        side: WidgetStatePropertyAll(BorderSide(color: Color(0x11000000))),
      ),
    );
  }
}