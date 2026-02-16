import 'package:hive/hive.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/domain/repositories/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._taskBox);

  final Box<Task> _taskBox;

  @override
  Future<List<Task>> getAll() async {
    final tasks = _taskBox.values
        .where((task) => task.id.trim().isNotEmpty)
        .toList(growable: false);

    // Stable ordering: newest first, then by id for deterministic ties.
    final sorted = [...tasks]
      ..sort((a, b) {
        final createdCompare = b.createdAt.compareTo(a.createdAt);
        if (createdCompare != 0) {
          return createdCompare;
        }
        return a.id.compareTo(b.id);
      });

    return sorted;
  }

  @override
  Future<void> create(Task task) async {
    if (task.id.trim().isEmpty) {
      throw ArgumentError('Task id cannot be empty.');
    }
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }
    if (_taskBox.containsKey(task.id)) {
      throw StateError('Task with id "${task.id}" already exists.');
    }

    // Data flow endpoint: this repository persists domain tasks into Hive.
    await _taskBox.put(task.id, task);
  }

  @override
  Future<void> update(Task task) async {
    if (task.id.trim().isEmpty) {
      throw ArgumentError('Task id cannot be empty.');
    }
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty.');
    }
    if (!_taskBox.containsKey(task.id)) {
      throw StateError('Cannot update missing task with id "${task.id}".');
    }

    await _taskBox.put(task.id, task);
  }

  @override
  Future<void> delete(String id) async {
    if (id.trim().isEmpty) {
      return;
    }

    await _taskBox.delete(id);
  }
}
