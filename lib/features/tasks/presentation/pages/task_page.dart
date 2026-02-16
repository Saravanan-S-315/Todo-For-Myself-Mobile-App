import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/presentation/controllers/task_controller.dart';

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
    final TextEditingController textController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final bool canSubmit = textController.text.trim().isNotEmpty;

            Future<void> submit() async {
              if (!canSubmit) {
                return;
              }
              await this.context.read<TaskController>().addTask(textController.text);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              title: const Text('Add task'),
              content: TextField(
                controller: textController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(hintText: 'Task title'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => submit(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canSubmit ? submit : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyTodo')),
      body: Consumer<TaskController>(
        builder: (BuildContext context, TaskController controller, Widget? child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet'));
          }

          return ListView.builder(
            itemCount: controller.tasks.length,
            itemBuilder: (BuildContext context, int index) {
              final task = controller.tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => controller.toggleTask(task.id),
                ),
                title: Text(task.title),
                subtitle: task.description == null || task.description!.isEmpty
                    ? null
                    : Text(task.description!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.deleteTask(task.id),
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
