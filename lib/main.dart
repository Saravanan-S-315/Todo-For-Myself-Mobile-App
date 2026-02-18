import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/core/data/local/hive_database.dart';
import 'package:mytodo/features/daily_notes/data/repositories/local_daily_note_repository.dart';
import 'package:mytodo/features/daily_notes/presentation/controllers/daily_note_controller.dart';
import 'package:mytodo/features/home/presentation/pages/home_page.dart';
import 'package:mytodo/features/settings/data/repositories/local_settings_repository.dart';
import 'package:mytodo/features/settings/presentation/controllers/settings_controller.dart';
import 'package:mytodo/features/tasks/data/repositories/local_task_repository.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveDatabase.initialize();

    runApp(
      MultiProvider(
        providers: [
          Provider(create: (_) => LocalTaskRepository(HiveDatabase.tasksBox())),
          Provider(create: (_) => LocalDailyNoteRepository()),
          Provider(create: (_) => LocalSettingsRepository()),
          ChangeNotifierProvider(
            create: (context) => TaskController(context.read<LocalTaskRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => DailyNoteController(
              context.read<LocalDailyNoteRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => SettingsController(
              context.read<LocalSettingsRepository>(),
            )..loadSettings(),
          ),
        ],
        child: const MyTodoApp(),
      ),
    );
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
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        final brightness = settingsController.isDarkModeEnabled
            ? Brightness.dark
            : Brightness.light;

        return MaterialApp(
          title: 'MyTodo',
          themeMode: settingsController.isDarkModeEnabled
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              platformBrightness: brightness,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
