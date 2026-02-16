import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_for_myself_mobile_app/core/data/local/hive_database.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/local_task_repository.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/presentation/controllers/task_controller.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/presentation/pages/task_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.initialize();

  final TaskRepository taskRepository = LocalTaskRepository();

  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.taskRepository,
  });

  final TaskRepository taskRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskController>(
      create: (_) => TaskController(taskRepository),
      child: MaterialApp(
        title: 'MyTodo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const TaskPage(),
      ),
    );
  }
}
