import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:diary/app.dart';
import 'package:diary/services/database_service.dart';
import 'package:diary/services/settings_service.dart';
import 'package:diary/providers/settings_provider.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/reports_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop SQLite.
  sqfliteFfiInit();

  // Resolve DB path from settings or default location.
  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

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
      child: const DiaryApp(),
    ),
  );
}
