import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/screens/add_project_screen.dart';
import 'package:time_tracker/screens/project_detail_screen.dart';
import '../provider/project_task_provider.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProjectTaskProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty && provider.tasks.isEmpty) {
            return const Center(child: Text("No projects or tasks yet."));
          }

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Projects",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...provider.projects.map(
                (project) => ListTile(
                  title: Text(project.name),
                  subtitle: Text("ID: ${project.id}"),
                  onTap: () {
                    // View tasks and add new tasks for this project
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsScreen(projectId: project.id),
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...provider.tasks.map((task) {
                final projectName = provider.getProjectName(task.projectId);
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text(projectName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsScreen(projectId: task.projectId),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectScreen()),
          );
        },
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }
}
