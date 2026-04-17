import 'package:flutter/material.dart';

class AllButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AllButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: const Row(
        children: [
          Text('all'),
          Icon(Icons.arrow_forward_ios_rounded, size: 15,),
        ],
      ),
    );
  }
}