import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/screens/add_project_screen.dart';
import 'package:time_tracker/screens/project_detail_screen.dart';
import '../provider/project_task_provider.dart';
import '../provider/time_entry_provider.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ProjectTaskProvider, TimeEntryProvider>(
        builder: (context, projectProvider, timeProvider, child) {
          if (projectProvider.projects.isEmpty) {
            return const Center(child: Text("No projects yet."));
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
              ...projectProvider.projects.map((project) {
                final taskStats = projectProvider.getTaskCompletion(project.id);
                final totalHours = timeProvider.getTotalHoursForProject(
                  project.id,
                );

                return ListTile(
                  title: Text(project.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tasks: ${taskStats["completed"]}/${taskStats["total"]}",
                      ),
                      Text("Date Started: ${project.startDate}"),
                      Text("Total Hours: $totalHours"),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsScreen(projectId: project.id),
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
