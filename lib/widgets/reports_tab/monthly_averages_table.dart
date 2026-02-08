import 'package:flutter/material.dart';
import 'package:diary/utils/color_utils.dart';

class MonthlyAveragesTable extends StatelessWidget {
  final List<Map<String, dynamic>> averages;

  const MonthlyAveragesTable({super.key, required this.averages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Monthly Averages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        // Fixed header.
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              SizedBox(
                  width: 120,
                  child: Text('Month',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 80,
                  child: Text('Avg Rating',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  width: 80,
                  child: Text('Entries',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(height: 1),
        // Scrollable list.
        Expanded(
          child: averages.isEmpty
              ? const Center(child: Text('No data available.'))
              : ListView.builder(
                  itemCount: averages.length,
                  itemBuilder: (context, index) {
                    final row = averages[index];
                    final month = row['month'] as String;
                    final avg = (row['avg'] as num).toDouble();
                    final count = row['count'] as int;

                    return Container(
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
                          SizedBox(width: 120, child: Text(month)),
                          SizedBox(
                            width: 80,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ratingToColor(avg.round())
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                avg.toStringAsFixed(1),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Text('$count'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
