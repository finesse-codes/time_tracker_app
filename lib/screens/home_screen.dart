import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/screens/time_entry_screen.dart';
import '../provider/time_entry_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Time Entries')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.entries.length,
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return ListTile(
                title: Text('${entry.projectId} - ${entry.totalTime} hours'),
                subtitle: Text(
                  '${entry.date.toString()} - Notes: ${entry.notes}',
                ),
                onTap: () {
                  // do something - detailed view or edit view
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
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        tooltip: 'Add Time Entry',
        child: Icon(Icons.add),
      ),
    );
  }
}
