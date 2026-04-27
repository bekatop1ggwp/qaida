import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/components/profile/app_bar/auth_profile_bar.dart';
import 'package:qaida/components/profile/history.dart';
import 'package:qaida/components/profile/history_skeleton.dart';
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
  bool _historyLoaded = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _prepareInitialProfile();
    _loadHistory();
  }

  Future<void> _prepareInitialProfile() async {
    Future.microtask(() async {
      await context.read<UserProvider>().refreshProfileInBackground();
    });
  }

  Future<void> _loadHistory() async {
    await context.read<HistoryProvider>().loadHistory();

    if (!mounted) return;

    setState(() {
      _historyLoaded = true;
    });
  }

  Future<void> _refreshProfilePage() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.wait([
        context.read<UserProvider>().refreshProfileInBackground(),
        context.read<HistoryProvider>().loadHistory(),
      ]);
    } finally {
      if (!mounted) return;

      setState(() {
        _historyLoaded = true;
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F6),
      appBar: const AuthProfileBar(),
      body: RefreshIndicator(
        onRefresh: _refreshProfilePage,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
          children: [
            if (!_historyLoaded)
              const HistorySkeleton()
            else if (history.isNotEmpty)
              History(history: history)
            else
              const SizedBox(height: 8),
            const LightContainer(
              margin: EdgeInsets.fromLTRB(20, 8, 20, 12),
              children: [
                ForwardButton(text: 'Сохраненные', page: Favorites()),
                ForwardButton(text: 'Посещенные места', page: Visits()),
                ForwardButton(text: 'Оставленные отзывы', page: Reviews()),
              ],
            ),
            const LightContainer(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                ForwardButton(text: 'Настройки', page: Settings()),
                ForwardButton(text: 'О нас', page: AboutUs()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}