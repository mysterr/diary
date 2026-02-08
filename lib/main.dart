import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:diary/app.dart';
import 'package:diary/services/database_service.dart';
import 'package:diary/services/settings_service.dart';
import 'package:diary/providers/settings_provider.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/reports_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all locale data for intl/calendar formatting.
  await initializeDateFormatting();

  // Initialize FFI for desktop SQLite.
  sqfliteFfiInit();

  // Initialize window manager.
  await windowManager.ensureInitialized();

  // Resolve DB path from settings or default location.
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  // Restore window geometry.
  final geometry = settingsService.getWindowGeometry();
  final windowOptions = WindowOptions(
    size: geometry != null
        ? Size(geometry.width, geometry.height)
        : const Size(1280, 720),
    center: geometry == null,
    minimumSize: const Size(800, 500),
    title: 'Diary',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (geometry != null) {
      await windowManager.setPosition(Offset(geometry.x, geometry.y));
    }
    await windowManager.show();
    await windowManager.focus();
  });

  String dbPath = settingsService.getDbPath() ?? '';
  if (dbPath.isEmpty) {
    final appDir = await getApplicationSupportDirectory();
    dbPath = '${appDir.path}${Platform.pathSeparator}diary.db';
    await settingsService.setDbPath(dbPath);
  }

  final databaseService = DatabaseService(dbPath);

  // Ensure the database is initialized before running the app.
  await databaseService.database;

  final diaryProvider = DiaryProvider(databaseService: databaseService);
  await diaryProvider.init();

  final reportsProvider = ReportsProvider(databaseService: databaseService);
  await reportsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsService: settingsService,
            databaseService: databaseService,
            initialDbPath: dbPath,
          ),
        ),
        ChangeNotifierProvider.value(value: diaryProvider),
        ChangeNotifierProvider.value(value: reportsProvider),
      ],
      child: DiaryApp(settingsService: settingsService),
    ),
  );
}
