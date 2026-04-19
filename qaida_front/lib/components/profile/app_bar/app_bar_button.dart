import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/profile/app_bar/app_bar_button_skeleton.dart';
import 'package:qaida/providers/user.provider.dart';
import 'package:qaida/views/profile/settings/settings.dart';

class AppBarButton extends StatelessWidget {
  const AppBarButton({super.key});

  String fullName(String? name, String? surname, String? email) {
    final full = '${name ?? ''} ${surname ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    return email ?? 'Профиль';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.hasMyself) {
      return const AppBarButtonSkeleton();
    }

    final user = userProvider.myself;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Settings(),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                fullName(user.name, user.surname, user.email),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243B63),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF243B63),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}