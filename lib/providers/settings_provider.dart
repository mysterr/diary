import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:diary/services/settings_service.dart';
import 'package:diary/services/database_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final DatabaseService _databaseService;

  String _dbPath;
  String? _locale;

  SettingsProvider({
    required SettingsService settingsService,
    required DatabaseService databaseService,
    required String initialDbPath,
  })  : _settingsService = settingsService,
        _databaseService = databaseService,
        _dbPath = initialDbPath,
        _locale = settingsService.getLocale();

  String get dbPath => _dbPath;

  String? get locale => _locale;

  /// Returns the locale to use — explicit setting or system locale with
  /// encoding suffix stripped (e.g. "en_US.UTF-8" → "en_US").
  String get effectiveLocale =>
      _locale ?? Platform.localeName.split('.').first;

  Future<void> setDbPath(String path) async {
    if (path == _dbPath) return;
    _dbPath = path;
    await _settingsService.setDbPath(path);
    await _databaseService.changePath(path);
    notifyListeners();
  }

  Future<void> setLocale(String? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    await _settingsService.setLocale(locale);
    notifyListeners();
  }
}
