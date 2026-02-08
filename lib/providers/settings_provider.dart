import 'package:flutter/foundation.dart';
import 'package:diary/services/settings_service.dart';
import 'package:diary/services/database_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  final DatabaseService _databaseService;

  String _dbPath;

  SettingsProvider({
    required SettingsService settingsService,
    required DatabaseService databaseService,
    required String initialDbPath,
  })  : _settingsService = settingsService,
        _databaseService = databaseService,
        _dbPath = initialDbPath;

  String get dbPath => _dbPath;

  Future<void> setDbPath(String path) async {
    if (path == _dbPath) return;
    _dbPath = path;
    await _settingsService.setDbPath(path);
    await _databaseService.changePath(path);
    notifyListeners();
  }
}
