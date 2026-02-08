import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/settings_provider.dart';
import 'package:diary/utils/color_utils.dart';
import 'package:diary/utils/date_utils.dart' as app_date_utils;

class DiaryCalendar extends StatelessWidget {
  const DiaryCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final settings = context.watch<SettingsProvider>();
    final today = app_date_utils.normalizeDate(DateTime.now());

    // intl FIRSTDAYOFWEEK: 0=Mon, 1=Tue, ..., 6=Sun
    const intlToTableCalendar = [
      StartingDayOfWeek.monday,
      StartingDayOfWeek.tuesday,
      StartingDayOfWeek.wednesday,
      StartingDayOfWeek.thursday,
      StartingDayOfWeek.friday,
      StartingDayOfWeek.saturday,
      StartingDayOfWeek.sunday,
    ];
    final locale = settings.effectiveLocale;
    final map = dateTimeSymbolMap();
    // Try exact locale (e.g. "en_US"), then strip encoding suffix
    // (e.g. "en_US.UTF-8" → "en_US"), then language only (e.g. "en").
    final clean = locale.split('.').first;
    final symbols = map[clean] ?? map[clean.split('_').first];
    final startingDay = symbols != null
        ? intlToTableCalendar[symbols.FIRSTDAYOFWEEK]
        : StartingDayOfWeek.sunday;

    return TableCalendar(
      locale: locale,
      startingDayOfWeek: startingDay,
      daysOfWeekHeight: 24,
      firstDay: DateTime(2000, 1, 1),
      lastDay: today,
      focusedDay: provider.selectedDate.isAfter(today)
          ? today
          : provider.selectedDate,
      selectedDayPredicate: (day) =>
          app_date_utils.isSameDayCustom(day, provider.selectedDate),
      enabledDayPredicate: (day) =>
          !app_date_utils.normalizeDate(day).isAfter(today),
      onDaySelected: (selectedDay, focusedDay) {
        provider.selectDate(selectedDay);
      },
      onPageChanged: (focusedDay) {
        // Reload month ratings when calendar page changes.
        provider.selectDate(focusedDay);
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, provider, isSelected: false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, provider, isSelected: true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(context, day, provider,
              isSelected: app_date_utils.isSameDayCustom(day, provider.selectedDate),
              isToday: true);
        },
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DiaryProvider provider, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final normalized = app_date_utils.normalizeDate(day);
    final rating = provider.monthRatings[normalized];
    final hasEntry = rating != null;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: hasEntry
            ? ratingToColor(rating).withValues(alpha: 0.4)
            : null,
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : isToday
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
    );
  }
}
