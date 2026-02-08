import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:diary/providers/diary_provider.dart';

class DiaryForm extends StatefulWidget {
  const DiaryForm({super.key});

  @override
  State<DiaryForm> createState() => _DiaryFormState();
}

class _DiaryFormState extends State<DiaryForm> {
  final _noteController = TextEditingController();
  DateTime? _lastSyncedDate;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _syncFromProvider(DiaryProvider provider) {
    // Sync controller text when the selected date changes (provider → form).
    if (_lastSyncedDate == null ||
        _lastSyncedDate != provider.selectedDate) {
      _lastSyncedDate = provider.selectedDate;
      if (_noteController.text != provider.noteText) {
        _noteController.text = provider.noteText;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    _syncFromProvider(provider);

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              dateFormat.format(provider.selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'How was your day?',
              ),
              maxLines: 10,
              onChanged: (value) {
                provider.noteText = value;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Rating: '),
                Text(
                  '${provider.rating}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Slider(
              value: provider.rating.toDouble(),
              min: -5,
              max: 5,
              divisions: 10,
              label: '${provider.rating}',
              onChanged: (value) {
                provider.rating = value.round();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (_noteController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a note.'),
                          ),
                        );
                        return;
                      }
                      provider.noteText = _noteController.text;
                      await provider.saveEntry();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Entry saved!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await provider.goToToday();
                  },
                  icon: const Icon(Icons.today),
                  label: const Text('Today'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
