import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _dbPathKey = 'db_path';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  String? getDbPath() => _prefs.getString(_dbPathKey);

  Future<void> setDbPath(String path) async {
    await _prefs.setString(_dbPathKey, path);
  }
}
