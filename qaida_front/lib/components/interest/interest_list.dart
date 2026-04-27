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
      child: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _InterestListSkeleton();
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            itemCount: provider.interests.length,
            itemBuilder: (_, index) => InterestItem(index: index),
          );
        },
      ),
    );
  }
}

class _InterestListSkeleton extends StatelessWidget {
  const _InterestListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final isLarge = index == 1 || index == 2;

        return Container(
          height: isLarge ? 116 : 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        );
      },
    );
  }
}