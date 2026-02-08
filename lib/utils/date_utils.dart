/// Strips time information, returning only the date portion.
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Returns true if [a] and [b] represent the same calendar day.
bool isSameDayCustom(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
