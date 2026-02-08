class DiaryEntry {
  final int? id;
  final DateTime date;
  final String note;
  final int rating;

  DiaryEntry({
    this.id,
    required this.date,
    required this.note,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'note': note,
      'rating': rating,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    final parts = (map['date'] as String).split('-');
    return DiaryEntry(
      id: map['id'] as int?,
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      note: map['note'] as String,
      rating: map['rating'] as int,
    );
  }

  DiaryEntry copyWith({
    int? id,
    DateTime? date,
    String? note,
    int? rating,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
      rating: rating ?? this.rating,
    );
  }
}
