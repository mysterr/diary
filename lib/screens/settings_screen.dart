import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/providers/settings_provider.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/reports_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    final settingsProvider = context.read<SettingsProvider>();
    _pathController = TextEditingController(text: settingsProvider.dbPath);
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Path',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Change the location of the SQLite database file. '
              'The app will create a new database if the file does not exist.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '/path/to/diary.db',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    final newPath = _pathController.text.trim();
                    if (newPath.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a valid path.')),
                      );
                      return;
                    }

                    final settingsProvider = context.read<SettingsProvider>();
                    await settingsProvider.setDbPath(newPath);

                    if (!context.mounted) return;

                    // Reinitialize providers with the new database.
                    final diaryProvider = context.read<DiaryProvider>();
                    await diaryProvider.init();

                    if (!context.mounted) return;

                    final reportsProvider = context.read<ReportsProvider>();
                    await reportsProvider.loadReportData();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Database path updated.')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
