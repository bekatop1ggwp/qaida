import 'package:flutter/material.dart';
import 'package:qaida/components/profile/app_bar/app_bar_button.dart';
import 'package:qaida/components/profile/app_bar/info.dart';
import 'package:qaida/components/search.dart';

class AuthProfileBar extends StatelessWidget implements PreferredSizeWidget  {
  const AuthProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20.0),
        ),
      ),
      title: const Column(
        children: [
          Search(),
          AppBarButton(),
          Info(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(200);
}