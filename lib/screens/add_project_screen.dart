import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project_model.dart';
import '../provider/project_task_provider.dart';

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
              onSaved: (value) => name = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description of the project';
                }
                return null;
              },
              onSaved: (value) => description = value!,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
                Provider.of<ProjectTaskProvider>(
                  context,
                  listen: false,
                ).addProject(
                  Project(
                    id: DateTime.now().toString(), // simple ID generation,
                    name: name,
                    description: description,
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
