# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Cross-platform desktop diary app (Linux/Windows). Users add daily notes with ratings (-5 to +5), view history in a table, and see reports with line charts and monthly averages.

## Tech Stack

- **Flutter Desktop** (3.38.x stable)
- **SQLite** via `sqflite_common_ffi`
- **Provider** for state management
- **table_calendar** for calendar widget
- **fl_chart** for line charts
- **shared_preferences** for persisting settings (DB path, window geometry)
- **window_manager** for window position/size persistence

## Build Commands

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get
flutter analyze
flutter build linux
flutter run -d linux
```

Binary output: `build/linux/x64/release/bundle/diary`

## Architecture

```
lib/
  main.dart                          # FFI init, window_manager init, service creation, MultiProvider, runApp
  app.dart                           # MaterialApp + Material 3 teal theme + WindowListener for geometry save
  models/
    diary_entry.dart                 # DiaryEntry model (id, date, note, rating)
  services/
    database_service.dart            # SQLite CRUD, report queries, schema
    settings_service.dart            # shared_preferences wrapper for DB path + window geometry
  providers/
    settings_provider.dart           # ChangeNotifier for DB path
    diary_provider.dart              # ChangeNotifier: selected date, form state, entries, month ratings
    reports_provider.dart            # ChangeNotifier: period, chart data, monthly averages
  screens/
    home_screen.dart                 # Scaffold + TabBar (Diary, Reports) + Settings icon
    settings_screen.dart             # DB path text field + save
  widgets/
    diary_tab/
      diary_tab.dart                 # Composes calendar + form + table
      diary_calendar.dart            # TableCalendar: colored days, future disabled
      diary_form.dart                # Note TextField (10 lines), rating Slider, Save/Today buttons
      diary_table.dart               # Fixed header Row + Expanded ListView.builder
    reports_tab/
      reports_tab.dart               # Period dropdown + chart + averages table
      rating_chart.dart              # fl_chart LineChart
      monthly_averages_table.dart    # Fixed header + scrollable list
  utils/
    color_utils.dart                 # ratingToColor: red(-5) -> green(+5) via Color.lerp
    date_utils.dart                  # normalizeDate, isSameDayCustom
assets/
  icon.svg                           # App icon (teal journal with bookmark)
```

## Key Design Decisions

- **One entry per day** — upsert via `ConflictAlgorithm.replace` on unique date column
- **Dates stored as TEXT** (yyyy-MM-dd) in SQLite for natural string comparison
- **ListView.builder** for tables (not DataTable) — fixed header + scrollable body
- **DiaryForm is StatefulWidget** — owns TextEditingController, syncs bidirectionally with provider
- **Calendar coloring** — `CalendarBuilders` with `ratingToColor()` background per day
- **Future days disabled** — `lastDay: DateTime.now()` + `enabledDayPredicate`
- **date_utils.dart imported with prefix** (`app_date_utils`) to avoid name collision with table_calendar's `normalizeDate`
- **Window geometry persistence** — saved via periodic timer (every 2s) + on close; Linux `onWindowResized`/`onWindowMoved` events are unreliable so the timer is the primary mechanism
- **Native GTK runner** (`linux/runner/my_application.cc`) has no hardcoded window size — `window_manager` controls size/position from Dart side

## Database Schema

Single table `diary_entries`:
- `id INTEGER PRIMARY KEY AUTOINCREMENT`
- `date TEXT NOT NULL UNIQUE` (yyyy-MM-dd)
- `note TEXT NOT NULL`
- `rating INTEGER NOT NULL`
- Index on `date`
