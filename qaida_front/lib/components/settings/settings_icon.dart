import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/user.provider.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().myself;
    return GestureDetector(
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await context.read<UserProvider>().changeAvatar();
          messenger.showSnackBar(
            const SnackBar(content: Text('Данные изменены')),
          );
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Ошибка. Попробуйте позже')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.only(left: 15.0, right: 15.0),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: user.imageId != null
              ? DecorationImage(
                  image: NetworkImage(
                    'http://192.168.8.6:8080/api/image/${user.imageId}',
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: user.imageId == null
            ? const Icon(
                Icons.image,
                color: Color(0xFF1E3050),
                size: 50.0,
              )
            : null,
      ),
    );
  }
}
