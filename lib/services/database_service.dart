import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:diary/models/diary_entry.dart';

class DatabaseService {
  Database? _db;
  String _dbPath;

  DatabaseService(this._dbPath);

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    return await databaseFactoryFfi.openDatabase(
      _dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE diary_entries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL UNIQUE,
              note TEXT NOT NULL,
              rating INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX idx_diary_entries_date ON diary_entries (date)',
          );
        },
      ),
    );
  }

  /// Change the database path. Closes existing connection and opens a new one.
  Future<void> changePath(String newPath) async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    _dbPath = newPath;
  }

  /// Insert or update an entry for the given date (one entry per day).
  Future<void> upsertEntry(DiaryEntry entry) async {
    final db = await database;
    final map = entry.toMap();
    await db.insert(
      'diary_entries',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a single entry by date.
  Future<DiaryEntry?> getEntryByDate(DateTime date) async {
    final db = await database;
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final results = await db.query(
      'diary_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    if (results.isEmpty) return null;
    return DiaryEntry.fromMap(results.first);
  }

  /// Get all entries ordered by date descending.
  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final results = await db.query(
      'diary_entries',
      orderBy: 'date DESC',
    );
    return results.map((m) => DiaryEntry.fromMap(m)).toList();
  }

  /// Get entries between two dates (inclusive), ordered by date ascending.
  Future<List<DiaryEntry>> getEntriesBetween(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startStr =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    final results = await db.query(
      'diary_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );
    return results.map((m) => DiaryEntry.fromMap(m)).toList();
  }

  /// Get entries for the last [months] months.
  Future<List<DiaryEntry>> getEntriesForPeriod(int months) async {
    final now = DateTime.now();
    final start = _monthsAgo(now, months - 1);
    final end = DateTime(now.year, now.month, now.day);
    return getEntriesBetween(start, end);
  }

  /// Get monthly averages for the last [months] months.
  /// Returns a list of maps with 'month' (yyyy-MM) and 'avg' (double).
  Future<List<Map<String, dynamic>>> getMonthlyAverages(int months) async {
    final db = await database;
    final now = DateTime.now();
    final start = _monthsAgo(now, months - 1);
    final startStr =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-01';
    final results = await db.rawQuery('''
      SELECT substr(date, 1, 7) AS month, AVG(rating) AS avg, COUNT(*) AS count
      FROM diary_entries
      WHERE date >= ?
      GROUP BY substr(date, 1, 7)
      ORDER BY month ASC
    ''', [startStr]);
    return results;
  }

  /// Get ratings keyed by day number for a specific month (for calendar coloring).
  Future<Map<DateTime, int>> getRatingsForMonth(int year, int month) async {
    final db = await database;
    final monthStr =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final results = await db.query(
      'diary_entries',
      columns: ['date', 'rating'],
      where: "substr(date, 1, 7) = ?",
      whereArgs: [monthStr],
    );
    final map = <DateTime, int>{};
    for (final row in results) {
      final parts = (row['date'] as String).split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      map[date] = row['rating'] as int;
    }
    return map;
  }

  /// Subtract [count] months from [from], returning the 1st of that month.
  static DateTime _monthsAgo(DateTime from, int count) {
    var year = from.year;
    var month = from.month - count;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    return DateTime(year, month, 1);
  }
}
