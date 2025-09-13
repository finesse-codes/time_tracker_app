import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/project_task_provider.dart';
import '../provider/time_entry_provider.dart';
import '../models/task_model.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);
    final timeProvider = Provider.of<TimeEntryProvider>(context);

    final project = projectProvider.getProjectById(projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Project not found")),
        body: const Center(child: Text("This project no longer exists.")),
      );
    }

    final tasks = projectProvider.getTasksForProject(projectId);

    return Scaffold(
      appBar: AppBar(title: Text("Project: ${project.name}")),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Dismissible(
            key: ValueKey(task.id),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // 👉 Swipe RIGHT = complete task
                if (task.status != "in progress") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⚠️ Task must be in progress before completing",
                      ),
                    ),
                  );
                  return false;
                }
                projectProvider.completeTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ ${task.name} marked complete")),
                );
                return false; // don't remove from list
              } else {
                // 👉 Swipe LEFT = delete task
                final hasEntries = projectProvider.hasTimeEntries(
                  task.id,
                  timeProvider.entries,
                );
                if (hasEntries) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ Cannot delete task with time entries"),
                    ),
                  );
                  return false;
                }

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Task"),
                    content: Text(
                      "Are you sure you want to delete '${task.name}'?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  projectProvider.deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("🗑️ ${task.name} deleted")),
                  );
                }
                return confirm ?? false;
              }
            },
            child: ListTile(
              title: Text(task.name),
              subtitle: Text("Status: ${task.status}"),
              trailing: IconButton(
                icon: Icon(
                  task.status == "completed"
                      ? Icons.check_circle
                      : Icons.hourglass_bottom,
                  color: task.status == "completed"
                      ? Colors.green
                      : Colors.orange,
                ),
                onPressed: () {
                  // Only allow toggle if currently completed
                  if (task.status == "completed") {
                    Provider.of<ProjectTaskProvider>(
                      context,
                      listen: false,
                    ).markTaskInProgress(task.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("🔄 ${task.name} marked as in progress"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⚠️ Only completed tasks can be reset"),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) {
              final _taskController = TextEditingController();
              final _notesController = TextEditingController();

              return AlertDialog(
                title: const Text("Add Task"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(labelText: "Task Name"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: "Notes (optional)",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = _taskController.text.trim();
                      final notes = _notesController.text.trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a task name"),
                          ),
                        );
                        return;
                      }

                      final newTask = Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        projectId: projectId,
                        name: name,
                        status: 'not started',
                        notes: notes,
                      );

                      projectProvider.addTask(newTask);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("🆕 Task '$name' added")),
                      );
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
