import 'package:flutter/foundation.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/services/database_service.dart';
import 'package:diary/utils/date_utils.dart';

class DiaryProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  DateTime _selectedDate = normalizeDate(DateTime.now());
  String _noteText = '';
  int _rating = 0;
  DiaryEntry? _currentEntry;
  List<DiaryEntry> _allEntries = [];
  Map<DateTime, int> _monthRatings = {};

  DiaryProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  DateTime get selectedDate => _selectedDate;
  // ignore: unnecessary_getters_setters
  String get noteText => _noteText;
  int get rating => _rating;
  DiaryEntry? get currentEntry => _currentEntry;
  List<DiaryEntry> get allEntries => _allEntries;
  Map<DateTime, int> get monthRatings => _monthRatings;

  // ignore: unnecessary_getters_setters
  set noteText(String value) {
    _noteText = value;
    // Don't notify — the TextField controller owns this state.
  }

  set rating(int value) {
    _rating = value;
    notifyListeners();
  }

  /// Initialize: load all entries and the entry for the selected date.
  Future<void> init() async {
    await _loadAllEntries();
    await _loadCurrentEntry();
    await _loadMonthRatings();
  }

  /// Select a date and load its entry.
  Future<void> selectDate(DateTime date) async {
    _selectedDate = normalizeDate(date);
    await _loadCurrentEntry();
    await _loadMonthRatings();
    notifyListeners();
  }

  /// Jump to today.
  Future<void> goToToday() async {
    await selectDate(DateTime.now());
  }

  /// Save (upsert) an entry for the selected date.
  Future<void> saveEntry() async {
    final entry = DiaryEntry(
      id: _currentEntry?.id,
      date: _selectedDate,
      note: _noteText,
      rating: _rating,
    );
    await _databaseService.upsertEntry(entry);
    await _loadAllEntries();
    await _loadCurrentEntry();
    await _loadMonthRatings();
    notifyListeners();
  }

  /// Load entry for a specific date from the table (when user taps a row).
  Future<void> loadEntryFromTable(DiaryEntry entry) async {
    _selectedDate = entry.date;
    _currentEntry = entry;
    _noteText = entry.note;
    _rating = entry.rating;
    await _loadMonthRatings();
    notifyListeners();
  }

  Future<void> _loadAllEntries() async {
    _allEntries = await _databaseService.getAllEntries();
  }

  Future<void> _loadCurrentEntry() async {
    _currentEntry = await _databaseService.getEntryByDate(_selectedDate);
    if (_currentEntry != null) {
      _noteText = _currentEntry!.note;
      _rating = _currentEntry!.rating;
    } else {
      _noteText = '';
      _rating = 0;
    }
  }

  Future<void> _loadMonthRatings() async {
    _monthRatings = await _databaseService.getRatingsForMonth(
      _selectedDate.year,
      _selectedDate.month,
    );
  }
}
