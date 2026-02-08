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
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
              elevation: 2,
              child: Row(
                children: [
                  const Expanded(
                    child: TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.book), text: 'Diary'),
                        Tab(icon: Icon(Icons.bar_chart), text: 'Reports'),
                      ],
                    ),
                  ),
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
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  DiaryTab(),
                  ReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
