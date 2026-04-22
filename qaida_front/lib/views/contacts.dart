import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _friends = const [
    {
      'name': 'Бектас Туржанов',
      'subtitle': 'В сети',
      'icon': Icons.person_rounded,
      'accent': Color(0xFF6C63FF),
      'online': true,
    },
    {
      'name': 'Еркебулан Ахмедия',
      'subtitle': '3 общих интереса',
      'icon': Icons.person_rounded,
      'accent': Color(0xFF4ECDC4),
      'online': false,
    },
    {
      'name': 'Алдияр Сейлханов',
      'subtitle': 'Недавно был в сети',
      'icon': Icons.person_rounded,
      'accent': Color(0xFFFF8A65),
      'online': false,
    },
    {
      'name': 'Айгерим С.',
      'subtitle': 'В сети',
      'icon': Icons.person_rounded,
      'accent': Color(0xFF5C6BC0),
      'online': true,
    },
  ];

  final List<Map<String, dynamic>> _groups = const [
    {
      'name': 'Любители кофе',
      'subtitle': '12 участников',
      'icon': Icons.groups_rounded,
      'accent': Color(0xFFFFB74D),
    },
    {
      'name': 'Куда сходить в Астане',
      'subtitle': '28 участников',
      'icon': Icons.travel_explore_rounded,
      'accent': Color(0xFF64B5F6),
    },
    {
      'name': 'Гастро места',
      'subtitle': '9 участников',
      'icon': Icons.restaurant_menu_rounded,
      'accent': Color(0xFF81C784),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final subtitle = (item['subtitle'] ?? '').toString().toLowerCase();
      return name.contains(query) || subtitle.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final friends = _filterItems(_friends);
    final groups = _filterItems(_groups);

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SearchField(controller: _searchController, onChanged: (_) => setState(() {})),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Друзья',
            count: friends.length,
            onSeeAll: () {},
          ),
          const SizedBox(height: 10),
          if (friends.isEmpty)
            const _EmptyBlock(
              icon: Icons.person_search_rounded,
              text: 'По вашему запросу друзья не найдены',
            )
          else
            ...friends.map((friend) => _ContactCard(
                  title: friend['name'] as String,
                  subtitle: friend['subtitle'] as String,
                  icon: friend['icon'] as IconData,
                  accent: friend['accent'] as Color,
                  trailing: friend['online'] == true
                      ? const _StatusChip(
                          text: 'online',
                          background: Color(0xFFE8F7EE),
                          foreground: Color(0xFF2E7D32),
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9AA3B2),
                        ),
                )),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Группы',
            count: groups.length,
            onSeeAll: () {},
          ),
          const SizedBox(height: 10),
          if (groups.isEmpty)
            const _EmptyBlock(
              icon: Icons.group_off_rounded,
              text: 'По вашему запросу группы не найдены',
            )
          else
            ...groups.map((group) => _ContactCard(
                  title: group['name'] as String,
                  subtitle: group['subtitle'] as String,
                  icon: group['icon'] as IconData,
                  accent: group['accent'] as Color,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9AA3B2),
                  ),
                )),
        ],
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
        decoration: InputDecoration(
          hintText: 'Поиск друзей и групп',
          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF98A2B3)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onSeeAll,
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
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6C63FF),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Все',
            style: TextStyle(fontWeight: FontWeight.w600),
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

class _StatusChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
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