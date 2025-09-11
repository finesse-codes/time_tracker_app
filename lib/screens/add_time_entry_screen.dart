import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_model.dart';
import '../provider/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});
  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId; // allow null
  String? taskId; // allow null
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),

      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              initialValue: projectId,
              items: <String>['project 1', 'project 2', 'project 3']
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  projectId = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Project'),
            ),
            DropdownButtonFormField<String>(
              initialValue: taskId,
              items: <String>['task 1', 'task 2', 'task 3']
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  taskId = newValue!;
                });
              },
              decoration: InputDecoration(labelText: 'Task'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Total Time (hours)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total time';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) => totalTime = double.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Notes'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some notes';
                }
                return null;
              },
              onSaved: (value) => notes = value!,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
                Provider.of<TimeEntryProvider>(
                  context,
                  listen: false,
                ).addTimeEntry(
                  TimeEntry(
                    id: DateTime.now().toString(), // simple ID generation
                    projectId: projectId ?? 'Unknonw project',
                    taskId: taskId ?? 'unknown task',
                    totalTime: totalTime,
                    date: date,
                    notes: notes,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
