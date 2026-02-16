import 'package:todo_for_myself_mobile_app/features/daily_notes/domain/models/daily_note.dart';

abstract interface class DailyNoteRepository {
  Future<List<DailyNote>> getAll();
  Future<DailyNote?> getById(String id);
  Future<DailyNote?> getByDate(DateTime date);
  Future<DailyNote> createOrUpdate({
    required DateTime date,
    required String content,
  });
  Future<void> delete(String id);
  Future<void> clearAll();
}
