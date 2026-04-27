import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/interests.provider.dart';
import 'package:qaida/providers/template.provider.dart';
import 'package:qaida/providers/theme.provider.dart';
import 'package:qaida/providers/user.provider.dart';

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isSaving = false;

  Future<void> handleSend(BuildContext context) async {
    final interestsProvider = context.read<InterestsProvider>();
    final userProvider = context.read<UserProvider>();

    final List<String> selectedIds = interestsProvider.getSelectedIds();

    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'access_token');

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    await interestsProvider.sendInterests(token, selectedIds);

    final selectedInterestObjects = interestsProvider.interests.where((interest) {
      return selectedIds.contains(interest['_id']?.toString());
    }).toList();

    await userProvider.updateInterestsLocally(selectedInterestObjects);

    Future.microtask(() async {
      try {
        await userProvider.getMe(silent: true);
        userProvider.notifyProfileReady();
      } catch (_) {}
    });
  }

  void navToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    context.read<TemplateProvider>().changeTemplatePage(0);
  }

  Future<void> _onNextPressed(BuildContext context) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await handleSend(context);

      if (!context.mounted) return;

      navToHome(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить интересы: $e'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
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
                onPressed: _isSaving ? null : () => navToHome(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFE9E9EC),
                  foregroundColor: blue,
                  disabledBackgroundColor: const Color(0xFFE9E9EC),
                  disabledForegroundColor: blue.withOpacity(0.5),
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
                onPressed: _isSaving ? null : () => _onNextPressed(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: blue.withOpacity(0.65),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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