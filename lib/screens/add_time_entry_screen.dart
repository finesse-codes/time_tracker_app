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
            // Project dropdown
            DropdownButtonFormField<String>(
              initialValue: projectId,
              items: projectProvider.projects
                  .map(
                    (project) => DropdownMenuItem(
                      value: project.id,
                      child: Text(project.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  projectId = value;
                  taskId = null; // reset when project changes
                });
              },
              decoration: const InputDecoration(labelText: 'Project'),
              validator: (value) =>
                  value == null ? 'Please select a project' : null,
            ),

            // Task dropdown (filtered by selected project)
            DropdownButtonFormField<String>(
              initialValue: taskId,
              items: projectId == null
                  ? []
                  : projectProvider.tasks
                        .where((task) => task.projectId == projectId)
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
              decoration: const InputDecoration(labelText: 'Task'),
              validator: (value) =>
                  value == null ? 'Please select a task' : null,
            ),

            // Time
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Time (hours)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter time spent';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
              onSaved: (value) => totalTime = double.parse(value!),
            ),

            // Notes
            TextFormField(
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notes = value ?? '',
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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
