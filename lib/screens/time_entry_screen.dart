import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/time_entry_provider.dart';
import 'add_time_entry_screen.dart';

class TimeEntryScreen extends StatelessWidget {
  const TimeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return const Center(child: Text("No time entries yet."));
          }

          return ListView.builder(
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return ListTile(
                title: Text('${entry.projectId} - ${entry.totalTime} hours'),
                subtitle: Text('${entry.date} - Notes: ${entry.notes}'),
                onTap: () {
                  // TODO: Replace with a details screen if you want
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
