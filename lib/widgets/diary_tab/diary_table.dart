import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/utils/color_utils.dart';

class DiaryTable extends StatefulWidget {
  const DiaryTable({super.key});

  @override
  State<DiaryTable> createState() => _DiaryTableState();
}

class _DiaryTableState extends State<DiaryTable> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final allEntries = provider.allEntries;
    final entries = _searchQuery.isEmpty
        ? allEntries
        : allEntries
            .where((e) =>
                e.note.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Column(
      children: [
        // Search field.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        // Fixed header row.
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              SizedBox(width: 100, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 60, child: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Note', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(height: 1),
        // Scrollable body.
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('No entries yet.'))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return InkWell(
                      onTap: () {
                        provider.loadEntryFromTable(entry);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(dateFormat.format(entry.date)),
                            ),
                            SizedBox(
                              width: 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ratingToColor(entry.rating)
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${entry.rating}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
