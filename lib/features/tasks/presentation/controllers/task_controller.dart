import 'package:flutter/foundation.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/domain/repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository);

  final TaskRepository _repository;

  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTasks() async {
    await _runGuarded(() async {
      final loadedTasks = await _repository.getAll();
      _tasks
        ..clear()
        ..addAll(loadedTasks);
      _sortTasks();
    });
  }

  Future<void> addTask(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Task title cannot be empty.';
      notifyListeners();
      return;
    }

    await _runGuarded(() async {
      final task = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: trimmedTitle,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Data flow: UI -> controller -> repository -> Hive.
      await _repository.create(task);
      _tasks.insert(0, task);
      _sortTasks();
    });
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    await _runGuarded(() async {
      final existing = _tasks[index];
      final updated = existing.copyWith(isCompleted: !existing.isCompleted);
      await _repository.update(updated);
      _tasks[index] = updated;
      _sortTasks();
    }, showLoader: false);
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    await _runGuarded(() async {
      await _repository.delete(id);
      _tasks.removeAt(index);
    }, showLoader: false);
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runGuarded(
    Future<void> Function() operation, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        _isLoading = true;
      }
      _errorMessage = null;
      notifyListeners();

      await operation();
    } catch (error, stackTrace) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('Task operation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      final createdCompare = b.createdAt.compareTo(a.createdAt);
      if (createdCompare != 0) {
        return createdCompare;
      }
      return a.id.compareTo(b.id);
    });
  }
}
