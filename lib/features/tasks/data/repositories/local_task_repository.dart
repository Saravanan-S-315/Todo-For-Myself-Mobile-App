import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_for_myself_mobile_app/core/data/local/hive_database.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/repositories/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const int _maxIdAttempts = 5;

  final Uuid _uuid;

  @override
  Future<Task> create({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    await HiveDatabase.initialize();

    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }

    final DateTime now = DateTime.now();
    final String id = await _generateUniqueId();
    final Task task = Task(
      id: id,
      title: trimmedTitle,
      description: description,
      dueDate: dueDate,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );

    await HiveDatabase.tasksBox().put(task.id, task);
    return task;
  }

  @override
  Future<void> delete(String id) async {
    await HiveDatabase.initialize();
    await HiveDatabase.tasksBox().delete(id);
  }

  @override
  Future<List<Task>> getAll() async {
    await HiveDatabase.initialize();
    final List<Task> tasks = HiveDatabase.tasksBox().values.toList(growable: false);
    tasks.sort((Task a, Task b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  Future<Task?> getById(String id) async {
    await HiveDatabase.initialize();
    return HiveDatabase.tasksBox().get(id);
  }

  @override
  Future<List<Task>> getByDate(DateTime date) async {
    await HiveDatabase.initialize();
    return HiveDatabase.tasksBox()
        .values
        .where((Task task) => _isSameDay(task.dueDate, date))
        .toList(growable: false);
  }

  @override
  Future<List<Task>> getToday() async {
    return getByDate(DateTime.now());
  }

  @override
  Future<Task> update(Task task) async {
    await HiveDatabase.initialize();

    final Task updated = task.copyWith(updatedAt: DateTime.now());
    await HiveDatabase.tasksBox().put(updated.id, updated);
    return updated;
  }

  @override
  Future<void> clearAll() async {
    await HiveDatabase.initialize();
    await HiveDatabase.tasksBox().clear();
  }

  Future<String> _generateUniqueId() async {
    for (int attempt = 0; attempt < _maxIdAttempts; attempt++) {
      final String id = _uuid.v4();
      final bool exists = HiveDatabase.tasksBox().containsKey(id);
      if (!exists) {
        return id;
      }
      debugPrint('Duplicate UUID detected for task id. Retrying...');
    }

    throw StateError('Failed to generate unique task id after $_maxIdAttempts attempts.');
  }

  bool _isSameDay(DateTime? value, DateTime target) {
    if (value == null) {
      return false;
    }

    return value.year == target.year &&
        value.month == target.month &&
        value.day == target.day;
  }
}
