import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/interest/interest_item/interest_item.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class InterestList extends StatefulWidget {
  const InterestList({super.key});

  @override
  State<InterestList> createState() => _InterestListState();
}

class _InterestListState extends State<InterestList> {
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  Future<void> _init() async {
    final interestsProvider = context.read<InterestsProvider>();
    final userProvider = context.read<UserProvider>();

    await interestsProvider.fetchInterests();

    if (userProvider.hasMyself) {
      interestsProvider.applyUserInterests(userProvider.myself.interests);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: FutureBuilder<void>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              if (kDebugMode) {
                print(snapshot.error);
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ошибка. Попробуйте позже'),
                  ),
                );

                Navigator.of(context).pop();
              });

              return const SizedBox.shrink();
            }

            final provider = context.watch<InterestsProvider>();

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: provider.interests.length,
              itemBuilder: (_, index) => InterestItem(index: index),
            );
          },
        ),
      ),
    );
  }
}