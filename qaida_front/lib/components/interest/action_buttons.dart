import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/template.provider.dart';
import 'package:qaida/providers/theme.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  Future<void> handleSend(BuildContext context) async {
    final List<String> interests =
        context.read<InterestsProvider>().getSelectedIds();

    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    await context.read<InterestsProvider>().sendInterests(token, interests);
    await context.read<UserProvider>().getMe();
  }

  void navToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    context.read<TemplateProvider>().changeTemplatePage(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InterestsProvider>();
    final int selectedCount =
        provider.selectedItems.where((element) => element).length;

    final Color blue = context.read<ThemeProvider>().lightBlack;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  navToHome(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFE9E9EC),
                  foregroundColor: blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await handleSend(context);
                    if (context.mounted) {
                      navToHome(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Не удалось сохранить интересы: $e'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Далее ($selectedCount)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}