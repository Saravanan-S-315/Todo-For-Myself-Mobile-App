import 'package:hive/hive.dart';

class DailyNote {
  const DailyNote({
    required this.id,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime date;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyNote copyWith({
    String? id,
    DateTime? date,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNote(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyNote.fromJson(Map<String, dynamic> json) {
    return DailyNote(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class DailyNoteAdapter extends TypeAdapter<DailyNote> {
  @override
  final int typeId = 2;

  @override
  DailyNote read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return DailyNote.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, DailyNote obj) {
    writer.writeMap(obj.toJson());
  }
}
