import 'package:flutter/foundation.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/services/database_service.dart';

class ReportsProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  int _periodMonths = 3;
  List<DiaryEntry> _periodEntries = [];
  List<Map<String, dynamic>> _monthlyAverages = [];

  ReportsProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  int get periodMonths => _periodMonths;
  List<DiaryEntry> get periodEntries => _periodEntries;
  List<Map<String, dynamic>> get monthlyAverages => _monthlyAverages;

  /// Initialize with default period.
  Future<void> init() async {
    await loadReportData();
  }

  /// Change the report period and reload data.
  Future<void> setPeriod(int months) async {
    _periodMonths = months;
    await loadReportData();
    notifyListeners();
  }

  /// Load chart data and monthly averages for the current period.
  Future<void> loadReportData() async {
    _periodEntries = await _databaseService.getEntriesForPeriod(_periodMonths);
    _monthlyAverages =
        await _databaseService.getMonthlyAverages(_periodMonths);
    notifyListeners();
  }
}
