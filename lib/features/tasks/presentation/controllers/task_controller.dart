import 'package:flutter/foundation.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._taskRepository);

  final TaskRepository _taskRepository;

  List<Task> _tasks = <Task>[];
  bool _isLoading = false;

  List<Task> get tasks => List<Task>.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _taskRepository.getAll();
    } catch (error, stackTrace) {
      debugPrint('TaskController.loadTasks error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask(String title) async {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    try {
      final Task created = await _taskRepository.create(title: trimmedTitle);
      _tasks = <Task>[created, ..._tasks];
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('TaskController.addTask error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> toggleTask(String id) async {
    final int index = _tasks.indexWhere((Task item) => item.id == id);
    if (index == -1) {
      return;
    }

    final Task task = _tasks[index];
    final bool nextCompleted = !task.isCompleted;
    final DateTime now = DateTime.now();

    final Task updated = task.copyWith(
      isCompleted: nextCompleted,
      completedAt: nextCompleted ? now : null,
      clearCompletedAt: !nextCompleted,
      updatedAt: now,
    );

    try {
      final Task saved = await _taskRepository.update(updated);
      final List<Task> nextTasks = List<Task>.from(_tasks);
      nextTasks[index] = saved;
      _tasks = nextTasks;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('TaskController.toggleTask error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskRepository.delete(id);
      _tasks = _tasks.where((Task item) => item.id != id).toList(growable: false);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('TaskController.deleteTask error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
