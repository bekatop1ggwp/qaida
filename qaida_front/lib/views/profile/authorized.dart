import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/components/profile/app_bar/auth_profile_bar.dart';
import 'package:qaida/components/profile/history.dart';
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
  Future<void>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getMe();
    await userProvider.fetchVisitedCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
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
            children: const [
              History(),
              LightContainer(
                margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                children: [
                  ForwardButton(text: 'Сохраненные', page: Favorites()),
                  ForwardButton(text: 'Посещенные места', page: Visits()),
                  ForwardButton(text: 'Оставленные отзывы', page: Reviews()),
                ],
              ),
              LightContainer(
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