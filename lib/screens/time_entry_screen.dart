import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/project_task_provider.dart';
import '../provider/time_entry_provider.dart';
import 'add_time_entry_screen.dart';

enum SortOption { date, project }

class TimeEntryScreen extends StatefulWidget {
  const TimeEntryScreen({super.key});

  @override
  State<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen> {
  SortOption _sortOption = SortOption.date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<SortOption>(
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.date,
                child: Text("Sort by Date"),
              ),
              PopupMenuItem(
                value: SortOption.project,
                child: Text("Sort by Project"),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return const Center(child: Text("No time entries yet."));
          }

          final projectProvider = Provider.of<ProjectTaskProvider>(
            context,
            listen: false,
          );

          // copy list so we don’t mutate provider.entries
          final entries = [...provider.entries];

          // apply sorting
          if (_sortOption == SortOption.date) {
            entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
          } else if (_sortOption == SortOption.project) {
            entries.sort((a, b) {
              final projectA = projectProvider.getProjectName(a.projectId);
              final projectB = projectProvider.getProjectName(b.projectId);
              return projectA.compareTo(projectB);
            });
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              final projectName = projectProvider.getProjectName(
                entry.projectId,
              );
              final taskName = projectProvider.getTaskName(
                entry.taskId,
                entry.projectId,
              );

              return ListTile(
                title: Text('$projectName - ${entry.totalTime} hours'),
                subtitle: Text(
                  '$taskName\n${entry.date.toString().split(" ").first}',
                ),
                isThreeLine: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tapped on ${entry.notes}")),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTimeEntryScreen()),
          );
        },
        tooltip: 'Add Time Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
