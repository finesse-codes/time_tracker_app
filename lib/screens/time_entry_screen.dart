import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';
import 'add_time_entry_screen.dart';
import '../models/time_model.dart';

enum GroupBy { date, project }

class TimeEntryScreen extends StatefulWidget {
  const TimeEntryScreen({super.key});

  @override
  State<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen> {
  GroupBy _groupBy = GroupBy.date; // ✅ default is date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<GroupBy>(
            onSelected: (value) => setState(() => _groupBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GroupBy.date,
                child: Text("Group by Date"),
              ),
              const PopupMenuItem(
                value: GroupBy.project,
                child: Text("Group by Project"),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          final entries = [...provider.entries];
          if (entries.isEmpty) {
            return const Center(child: Text("No time entries yet."));
          }

          if (_groupBy == GroupBy.date) {
            return _buildByDate(entries, context);
          } else {
            return _buildByProject(entries, context);
          }
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

  // ---------------------
  // GROUPING BY DATE
  // ---------------------
  Widget _buildByDate(List<TimeEntry> entries, BuildContext context) {
    entries.sort((a, b) => b.date.compareTo(a.date));
    final Map<String, List<TimeEntry>> grouped = {};

    for (final e in entries) {
      final key = _formatDate(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final children = <Widget>[];
    grouped.forEach((dateKey, dayEntries) {
      final totalHours = dayEntries.fold<double>(
        0.0,
        (sum, el) => sum + el.totalTime,
      );

      children.add(_header("$dateKey — ${totalHours.toStringAsFixed(1)} hrs"));
      children.addAll(_entryTiles(dayEntries, context));
    });

    return ListView(children: children);
  }

  // ---------------------
  // GROUPING BY PROJECT
  // ---------------------
  Widget _buildByProject(List<TimeEntry> entries, BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(
      context,
      listen: false,
    );

    final Map<String, List<TimeEntry>> grouped = {};
    for (final e in entries) {
      final projectName = projectProvider.getProjectName(e.projectId);
      grouped.putIfAbsent(projectName, () => []).add(e);
    }

    final children = <Widget>[];
    grouped.forEach((projName, projEntries) {
      final totalHours = projEntries.fold<double>(
        0.0,
        (sum, el) => sum + el.totalTime,
      );

      children.add(_header("$projName — ${totalHours.toStringAsFixed(1)} hrs"));
      children.addAll(_entryTiles(projEntries, context));
    });

    return ListView(children: children);
  }

  // ---------------------
  // HELPERS
  // ---------------------
  Widget _header(String text) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  List<Widget> _entryTiles(List<TimeEntry> entries, BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(
      context,
      listen: false,
    );

    return entries.map((time) {
      final projectName = projectProvider.getProjectName(time.projectId);
      final taskName = projectProvider.getTaskName(time.taskId);

      return ListTile(
        title: Text("$projectName (${time.totalTime.toStringAsFixed(1)} hrs)"),
        subtitle: Text("$taskName — ${time.notes}"),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Tapped on ${time.notes}")));
        },
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    return "${_weekdayName(date.weekday)}, "
        "${date.day} ${_monthName(date.month)}";
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "";
    }
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month];
  }
}
