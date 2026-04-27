import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/components/forward_button.dart';
import 'package:qaida/components/light_container.dart';
import 'package:qaida/providers/history.provider.dart';
import 'package:qaida/views/interests.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return LightContainer(
      children: [
        const ForwardButton(
          text: 'Изменить интересы',
          icon: false,
          page: Interests(),
        ),
        ForwardButton(
          text: 'Удалить историю просмотра',
          icon: false,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Удалить историю просмотра?'),
                  content: const Text(
                    'Будут удалены только недавно просмотренные места на этом устройстве. Данные посещений не будут затронуты.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) return;

            await context.read<HistoryProvider>().clearHistory();

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('История просмотра удалена'),
              ),
            );
          },
        ),
        const ForwardButton(
          text: 'Удалить историю посещений',
          icon: false,
        ),
      ],
    );
  }
}