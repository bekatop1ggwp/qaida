import 'package:flutter/material.dart';
import 'package:qaida/components/interest/action_buttons.dart';
import 'package:qaida/components/interest/interest_list.dart';
import 'package:qaida/components/interest/interest_template.dart';

class Interests extends StatelessWidget {
  const Interests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: InterestTemplate(
        children: [
          _InterestHeader(),
          SizedBox(height: 18),
          InterestList(),
          ActionButtons(),
        ],
      ),
    );
  }
}

class _InterestHeader extends StatelessWidget {
  const _InterestHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите\nинтересы',
            style: TextStyle(
              fontSize: 36,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: Color(0xFF1D1D24),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Это поможет нам составлять более точные рекомендации для посещения',
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A3A45),
            ),
          ),
        ],
      ),
    );
  }
}