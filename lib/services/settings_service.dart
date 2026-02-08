import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _dbPathKey = 'db_path';
  static const _winXKey = 'window_x';
  static const _winYKey = 'window_y';
  static const _winWidthKey = 'window_width';
  static const _winHeightKey = 'window_height';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  String? getDbPath() => _prefs.getString(_dbPathKey);

  Future<void> setDbPath(String path) async {
    await _prefs.setString(_dbPathKey, path);
  }

  ({double x, double y, double width, double height})? getWindowGeometry() {
    final x = _prefs.getDouble(_winXKey);
    final y = _prefs.getDouble(_winYKey);
    final w = _prefs.getDouble(_winWidthKey);
    final h = _prefs.getDouble(_winHeightKey);
    if (x == null || y == null || w == null || h == null) return null;
    return (x: x, y: y, width: w, height: h);
  }

  Future<void> setWindowGeometry(
      double x, double y, double width, double height) async {
    await Future.wait([
      _prefs.setDouble(_winXKey, x),
      _prefs.setDouble(_winYKey, y),
      _prefs.setDouble(_winWidthKey, width),
      _prefs.setDouble(_winHeightKey, height),
    ]);
  }
}
