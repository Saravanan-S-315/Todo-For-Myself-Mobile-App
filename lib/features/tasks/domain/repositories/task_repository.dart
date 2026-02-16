import 'package:mytodo/features/tasks/domain/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<void> create(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
}
