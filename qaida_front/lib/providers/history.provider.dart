import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/components/profile/app_bar/auth_profile_bar.dart';
import 'package:qaida/components/profile/history.dart';
import 'package:qaida/providers/history.provider.dart';
import 'package:qaida/providers/user.provider.dart';
import 'package:qaida/views/profile/about_us.dart';
import 'package:qaida/views/profile/favorites.dart';
import 'package:qaida/views/profile/reviews.dart';
import 'package:qaida/views/profile/settings/settings.dart';
import 'package:qaida/views/profile/visits.dart';

class Authorized extends StatefulWidget {
  const Authorized({super.key});

  @override
  State<Authorized> createState() => _AuthorizedState();
}

class _AuthorizedState extends State<Authorized> {
  Future<void>? _profileFuture;
  Future<void>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _historyFuture = _loadHistory();
  }

  Future<void> _loadProfile() async {
    final userProvider = context.read<UserProvider>();

    await Future.wait([
      userProvider.getMe(silent: true),
      userProvider.fetchVisitedCount(silent: true),
    ]);

    if (mounted) {
      userProvider.notifyProfileReady();
    }
  }

  Future<void> _loadHistory() async {
    await context.read<HistoryProvider>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки профиля'));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF2F3F6),
          appBar: const AuthProfileBar(),
          body: ListView(
            children: [
              FutureBuilder<void>(
                future: _historyFuture,
                builder: (context, historySnapshot) {
                  final history = context.watch<HistoryProvider>().history;

                  if (historySnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (history.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return History(history: history);
                },
              ),
              const LightContainer(
                margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                children: [
                  ForwardButton(text: 'Сохраненные', page: Favorites()),
                  ForwardButton(text: 'Посещенные места', page: Visits()),
                  ForwardButton(text: 'Оставленные отзывы', page: Reviews()),
                ],
              ),
              const LightContainer(
                margin: EdgeInsets.all(20.0),
                children: [
                  ForwardButton(text: 'Настройки', page: Settings()),
                  ForwardButton(text: 'О нас', page: AboutUs()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}