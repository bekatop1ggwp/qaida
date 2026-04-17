import 'package:flutter/material.dart';
import 'package:qaida/components/forward_button_text.dart';

class ForwardButton extends StatelessWidget {
  final String text;
  final Widget? page;
  final String? label;
  final bool icon;
  final Icon? leading;
  final VoidCallback? onPressed;

  const ForwardButton({
    super.key,
    required this.text,
    this.page,
    this.label,
    this.icon = true,
    this.leading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) onPressed!();
        if (page == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page!,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (leading != null) leading!,

                label == null ?
                Unlabeled(text: text) :
                Labeled(label: label!, text: text,),
              ],
            ),
          ),

          if (icon) const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF1E3050),
          ),
        ],
      ),
    );
  }
}