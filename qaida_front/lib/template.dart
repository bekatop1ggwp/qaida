import 'package:flutter/material.dart';
import 'package:qaida/views/categories/categories.dart';
import 'package:qaida/views/contacts.dart';
import 'package:qaida/views/home/home.dart';
import 'package:qaida/views/profile/profile.dart';

class Template extends StatelessWidget {
  const Template({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color(0xFFF2F3F6),
        body: TabBarView(
          children: [
            Main(),
            Categories(),
            Contacts(),
            Profile(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Главная'),
            Tab(icon: Icon(Icons.list), text: 'Категории'),
            Tab(icon: Icon(Icons.people), text: 'Контакты'),
            Tab(icon: Icon(Icons.person), text: 'Профиль'),
          ],
        ),
      ),
    );
  }
}
