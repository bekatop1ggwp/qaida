import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/interest/interest_item/interest_item.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class InterestList extends StatelessWidget {
  const InterestList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: context.read<InterestsProvider>().fetchInterests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка. Попробуйте позже')),
            );
            Navigator.of(context).pop();
            return Container();
          } else {
            try {
              final user = context.watch<UserProvider>().myself;
              context
                  .read<InterestsProvider>()
                  .getUserInterests(user.interests);
            } catch (e) {
              if (kDebugMode) print(e);
            }
            return ListView.builder(
              itemCount: context.watch<InterestsProvider>().interests.length,
              itemBuilder: (_, index) => InterestItem(index: index),
            );
          }
        },
      ),
    );
  }
}
