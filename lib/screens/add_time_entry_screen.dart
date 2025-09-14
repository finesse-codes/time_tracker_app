import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_model.dart';
import '../models/task_model.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  // projectID and TaskId can be passed in, optionally
  final String? initialProjectId;
  final String? initialTaskId;

  const AddTimeEntryScreen({
    super.key,
    this.initialProjectId,
    this.initialTaskId,
  });

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  String notes = '';
  final _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    projectId = widget.initialProjectId;
    taskId = widget.initialTaskId;
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project dropdown
            DropdownButtonFormField<String>(
              initialValue: projectId,
              items: projectProvider.projects.map((project) {
                return DropdownMenuItem(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  projectId = value;
                  taskId = null;
                  _newTaskController.clear();
                });
              },
              validator: (value) => value == null ? 'Select a project' : null,
              decoration: const InputDecoration(labelText: 'Project'),
            ),

            const SizedBox(height: 12),

            // Task dropdown (optional)
            if (projectId != null)
              DropdownButtonFormField<String>(
                initialValue: taskId,
                items: projectProvider
                    .getTasksForProject(projectId!)
                    .map(
                      (task) => DropdownMenuItem(
                        value: task.id,
                        child: Text(task.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    taskId = value;
                    _newTaskController.clear();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select an existing task (optional)',
                ),
              ),

            const SizedBox(height: 12),

            // New task input
            TextFormField(
              controller: _newTaskController,
              decoration: const InputDecoration(
                labelText: 'Or enter a new task',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    taskId = null; // clear selection if typing new task
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Time
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Time (hours)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter time spent';
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
              onSaved: (value) => totalTime = double.parse(value!),
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notes = value ?? '',
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (projectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a project')),
                    );
                    return;
                  }

                  // Either use selected task or create new task
                  String finalTaskId;
                  if (_newTaskController.text.trim().isNotEmpty) {
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: projectId!,
                      name: _newTaskController.text.trim(),
                      status: 'not started',
                      notes: '',
                    );
                    projectProvider.addTask(newTask);
                    finalTaskId = newTask.id;
                  } else if (taskId != null) {
                    finalTaskId = taskId!;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select or enter a task'),
                      ),
                    );
                    return;
                  }

                  _formKey.currentState!.save();

                  Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  ).addTimeEntry(
                    TimeEntry(
                      id: DateTime.now().toIso8601String(),
                      projectId: projectId!,
                      taskId: finalTaskId,
                      totalTime: totalTime,
                      date: DateTime.now(),
                      notes: notes,
                    ),
                    projectProvider,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
