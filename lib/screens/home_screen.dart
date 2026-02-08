import 'package:flutter/material.dart';
import 'package:diary/widgets/diary_tab/diary_tab.dart';
import 'package:diary/widgets/reports_tab/reports_tab.dart';
import 'package:diary/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diary'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Diary'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Reports'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            DiaryTab(),
            ReportsTab(),
          ],
        ),
      ),
    );
  }
}
