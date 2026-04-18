import 'package:flutter/material.dart';
import 'package:qaida/components/profile/app_bar/app_bar_button.dart';
import 'package:qaida/components/profile/app_bar/info.dart';

class AuthProfileBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 140,
      titleSpacing: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      title: const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBarButton(),
            SizedBox(height: 12),
            Info(),
          ],
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(16),
        child: SizedBox(height: 16),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(148);
}