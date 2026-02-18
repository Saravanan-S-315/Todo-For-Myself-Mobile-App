import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
    });
  }

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var currentValue = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSubmit = currentValue.trim().isNotEmpty;

            return AlertDialog(
              title: const Text('Add Task'),
              content: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setDialogState(() {
                      currentValue = value;
                    });
                  },
                  onSubmitted: (_) async {
                    if (!canSubmit) {
                      return;
                    }
                    await context.read<TaskController>().addTask(currentValue);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canSubmit
                      ? () async {
                          await context
                              .read<TaskController>()
                              .addTask(currentValue);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskController>(
        builder: (context, taskController, _) {
          if (taskController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskController.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      taskController.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: taskController.loadTasks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (taskController.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: taskController.tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final task = taskController.tasks[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => taskController.toggleTask(task.id),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => taskController.deleteTask(task.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
