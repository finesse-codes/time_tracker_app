import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/screens/add_project_screen.dart';
import 'package:time_tracker/screens/project_detail_screen.dart';
import 'package:time_tracker/utils/app_card.dart';
import 'package:time_tracker/utils/task_progress_indicator.dart';
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
              ...projectProvider.projects.map((project) {
                final taskStats = projectProvider.getTaskCompletion(project.id);
                final totalHours = timeProvider
                    .getTotalHoursForProject(project.id)
                    .toStringAsFixed(2);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1.0,
                    vertical: 3.0,
                  ),
                  child: AppCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectDetailsScreen(projectId: project.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text("started ${project.startDate}"),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    totalHours,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "hours",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              TaskProgressIndicator(
                                completed: taskStats["completed"] ?? 0,
                                total: taskStats["total"] ?? 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
