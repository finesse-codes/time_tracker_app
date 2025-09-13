import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_model.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  String notes = '';

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
                });
              },
              validator: (value) => value == null ? 'Select a project' : null,
              decoration: const InputDecoration(labelText: 'Project'),
            ),
            DropdownButtonFormField<String>(
              initialValue: taskId,
              items: projectProvider
                  .getTasksForProject(projectId ?? "")
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
                });
              },
              validator: (value) => value == null ? 'Select a task' : null,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notes = value ?? '',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (projectId == null || taskId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a project and task'),
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
                      taskId: taskId!,
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
