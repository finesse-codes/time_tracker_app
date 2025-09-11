import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/project_task_provider.dart';
import '../models/task_model.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context, listen: true);
    final project = provider.getProjectById(widget.projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Project not found")),
        body: const Center(child: Text("This project no longer exists.")),
      );
    }

    final tasks = provider.getTasksForProject(widget.projectId);

    return Scaffold(
      appBar: AppBar(title: Text("Project: ${project.name}")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${project.name} - ${tasks.length} Tasks',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Scrollable list of tasks
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("No tasks yet."))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(task.name),
                        subtitle: Text("Status: ${task.status}"),
                        onTap: () {
                          // TODO: Open TaskDetailsScreen if desired
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tapped on ${task.name}")),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, provider, widget.projectId);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(
    BuildContext context,
    ProjectTaskProvider provider,
    String projectId,
  ) {
    final _taskNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          controller: _taskNameController,
          decoration: const InputDecoration(labelText: "Task Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _taskNameController.text.trim();
              if (name.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().toString(),
                  projectId: projectId,
                  name: name,
                  notes: 'this is a note',
                  status: "Not Started", // default status
                );
                provider.addTask(newTask); // update provider
                Navigator.pop(context); // close dialog
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
