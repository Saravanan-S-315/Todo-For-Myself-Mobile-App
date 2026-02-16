import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getAll();
  Future<Task?> getById(String id);
  Future<List<Task>> getByDate(DateTime date);
  Future<List<Task>> getToday();
  Future<Task> create({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  });
  Future<Task> update(Task task);
  Future<void> delete(String id);
  Future<void> clearAll();
}
