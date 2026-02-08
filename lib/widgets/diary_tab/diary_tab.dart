import 'package:flutter/material.dart';
import 'package:diary/widgets/diary_tab/diary_calendar.dart';
import 'package:diary/widgets/diary_tab/diary_form.dart';
import 'package:diary/widgets/diary_tab/diary_table.dart';

class DiaryTab extends StatelessWidget {
  const DiaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: calendar + form.
        SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: const [
                DiaryCalendar(),
                DiaryForm(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Right side: entries table.
        const Expanded(
          child: DiaryTable(),
        ),
      ],
    );
  }
}
