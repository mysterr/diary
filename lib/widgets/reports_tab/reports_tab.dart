import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/providers/reports_provider.dart';
import 'package:diary/widgets/reports_tab/rating_chart.dart';
import 'package:diary/widgets/reports_tab/monthly_averages_table.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  static const _periodOptions = [
    (months: 1, label: 'Last month'),
    (months: 3, label: 'Last 3 months'),
    (months: 6, label: 'Last 6 months'),
    (months: 12, label: 'Last year'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: chart area.
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Report Period:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: provider.periodMonths,
                      items: _periodOptions.map((opt) {
                        return DropdownMenuItem<int>(
                          value: opt.months,
                          child: Text(opt.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setPeriod(value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RatingChart(entries: provider.periodEntries),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: monthly averages table.
        Expanded(
          flex: 2,
          child: MonthlyAveragesTable(averages: provider.monthlyAverages),
        ),
      ],
    );
  }
}
