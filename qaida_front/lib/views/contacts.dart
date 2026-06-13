import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaida/providers/user.provider.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.fetchFriends();
      userProvider.fetchFriendSuggestions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List _filterItems(List items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final name = '${item['name'] ?? ''} ${item['surname'] ?? ''}'.toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();

      return name.contains(query) || email.contains(query);
    }).toList();
  }

  String _getFullName(dynamic user) {
    final name = (user['name'] ?? '').toString();
    final surname = (user['surname'] ?? '').toString();
    final fullName = '$name $surname'.trim();

    return fullName.isEmpty ? 'Пользователь' : fullName;
  }

  Future<void> _addFriend(String friendId) async {
    try {
      await context.read<UserProvider>().addFriend(friendId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пользователь добавлен в друзья'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось добавить пользователя'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final friends = _filterItems(userProvider.friends);
    final suggestions = _filterItems(userProvider.friendSuggestions);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Контакты',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<UserProvider>().fetchFriends(),
            context.read<UserProvider>().fetchFriendSuggestions(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            _SectionHeader(
              title: 'Друзья',
              count: friends.length,
            ),
            const SizedBox(height: 10),

            if (userProvider.isLoadingFriends)
              const _LoadingBlock()
            else if (friends.isEmpty)
              const _EmptyBlock(
                icon: Icons.person_search_rounded,
                text: 'Пока нет контактов. Добавляйте пользователей с похожими интересами.',
              )
            else
              ...friends.map(
                (user) => _ContactCard(
                  title: _getFullName(user),
                  subtitle: (user['email'] ?? '').toString(),
                  icon: Icons.person_rounded,
                  accent: const Color(0xFF6C63FF),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA3B2),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _SectionHeader(
              title: 'Возможно, вы знакомы',
              count: suggestions.length,
            ),
            const SizedBox(height: 10),

            if (userProvider.isLoadingFriendSuggestions)
              const _LoadingBlock()
            else if (suggestions.isEmpty)
              const _EmptyBlock(
                icon: Icons.person_add_alt_1_rounded,
                text: 'Пока нет предложений. Добавляйте интересы, чтобы находить похожих пользователей.',
              )
            else
              ...suggestions.map(
                (user) => _ContactCard(
                  title: _getFullName(user),
                  subtitle: '${user['matchingInterestsCount'] ?? 0} общих интереса',
                  icon: Icons.person_rounded,
                  accent: const Color(0xFF4ECDC4),
                  trailing: IconButton(
                    onPressed: () => _addFriend(user['_id'].toString()),
                    icon: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        enableSuggestions: true,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: 'Поиск друзей',
          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF98A2B3),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEFF5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget trailing;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7D8597),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyBlock({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: const Color(0xFF98A2B3),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}