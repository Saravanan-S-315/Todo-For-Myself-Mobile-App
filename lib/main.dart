import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/tasks/data/repositories/local_task_repository.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/domain/repositories/task_repository.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:mytodo/features/tasks/presentation/pages/task_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    const tasksBoxName = 'tasks_box';
    final taskBox = Hive.isBoxOpen(tasksBoxName)
        ? Hive.box<Task>(tasksBoxName)
        : await Hive.openBox<Task>(tasksBoxName);

    final taskRepository = LocalTaskRepository(taskBox);
    runApp(MyTodoApp(taskRepository: taskRepository));
  } catch (error, stackTrace) {
    debugPrint('Failed to initialize app: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(const _StartupErrorApp());
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to start MyTodo. Please restart the app.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({
    super.key,
    required this.taskRepository,
  });

  final TaskRepository taskRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Data flow: UI widgets call TaskController methods, the controller
      // coordinates repository operations, and the repository reads/writes Hive.
      create: (_) => TaskController(taskRepository),
      child: MaterialApp(
        title: 'MyTodo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TaskPage(),
      ),
    );
  }
}
