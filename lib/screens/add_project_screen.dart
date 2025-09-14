import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project_model.dart';
import '../provider/project_task_provider.dart';
import '../models/task_model.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});
  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  // variables needed for this page
  String name = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),

      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Name of project
            // Description
            // automatically create an ID
            TextFormField(
              decoration: InputDecoration(labelText: 'Project Name'),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the project name';
                }

                return null;
              },
              onSaved: (value) => name = value!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description of the project';
                }
                return null;
              },
              onSaved: (value) => description = value!.trim(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final projectProvider = Provider.of<ProjectTaskProvider>(
                  context,
                  listen: false,
                );
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();

                // Create New Project
                final newProject = Project(
                  id: DateTime.now().toString(),
                  name: name,
                  description: description,
                );

                // save project
                context.read<ProjectTaskProvider>().addProject(newProject);
                // force user to create at least one task immediately
                await _promptAddFirstTask(
                  context,
                  projectProvider,
                  newProject.id,
                );

                // after at least one task added, pop the AddProjectScreen
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('save'),
            ),
          ],
        ),
      ),
    );
  }

  // Shows a non-dismissible dialog that requires the user to add at least one task.
  Future<void> _promptAddFirstTask(
    BuildContext context,
    ProjectTaskProvider projectProvider,
    String projectId,
  ) async {
    final _taskController = TextEditingController();

    // barrierDismissible: false -> user can't dismiss the dialog by tapping outside
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final hasText = _taskController.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('Add first task for this project'),
              content: TextField(
                controller: _taskController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Task name'),
                onChanged: (_) {
                  // update the Save button enabled state
                  setState(() {});
                },
              ),
              actions: [
                // Optionally you could provide a "Cancel project creation" action.
                // For strict "must create a task" behavior we omit Cancel.
                ElevatedButton(
                  onPressed: hasText
                      ? () {
                          final taskName = _taskController.text.trim();

                          final newTask = Task(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            projectId: projectId,
                            name: taskName,
                            status: 'not started',
                            notes: '',
                          );

                          projectProvider.addTask(newTask);
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        );
      },
    );

    _taskController.dispose();
  }
}
