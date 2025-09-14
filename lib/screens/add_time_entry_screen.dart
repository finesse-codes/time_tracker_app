import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_model.dart';
import '../models/task_model.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';
import 'dart:async';

class AddTimeEntryScreen extends StatefulWidget {
  // projectID and TaskId can be passed in, optionally
  final String? initialProjectId;
  final String? initialTaskId;
  bool useTimer = false;

  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final _hoursController = TextEditingController();

  AddTimeEntryScreen({super.key, this.initialProjectId, this.initialTaskId});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  String notes = '';
  bool _isRunning = false;
  bool _isPaused = false;
  final _newTaskController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    projectId = widget.initialProjectId;
    taskId = widget.initialTaskId;
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning && !_isPaused) return; // already running
    _isRunning = true;
    _isPaused = false;

    widget._timer?.cancel();
    widget._timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        widget._elapsed = Duration(seconds: widget._elapsed.inSeconds + 1);
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning && !_isPaused) {
      widget._timer?.cancel();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _resumeTimer() {
    if (_isRunning && _isPaused) {
      _startTimer();
    }
  }

  void _stopTimer() {
    widget._timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    // convert elapsed time into hours (decimal)
    final hours = widget._elapsed.inHours;
    final minutes = widget._elapsed.inMinutes.remainder(60);

    // Fill in total time automatically (with HH:mm format)
    _timeController.text =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Switch between manual hours and timer
            SwitchListTile(
              title: const Text("Use Timer"),
              value: widget.useTimer,
              onChanged: (val) {
                setState(() {
                  widget.useTimer = val;
                });
              },
            ),
            // If using timer → show elapsed + start/stop
            if (widget.useTimer) ...[
              Text(
                _formatDuration(widget._elapsed),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning) ...[
                    ElevatedButton(
                      onPressed: _startTimer,
                      child: const Text("Start"),
                    ),
                  ] else if (_isPaused) ...[
                    ElevatedButton(
                      onPressed: _resumeTimer,
                      child: const Text("Resume"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _stopTimer,
                      child: const Text("Stop"),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _pauseTimer,
                      child: const Text("Pause"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _stopTimer,
                      child: const Text("Stop"),
                    ),
                  ],
                ],
              ),
            ] else ...[
              // Manual time entry
              TextFormField(
                controller: widget._hoursController,
                decoration: const InputDecoration(
                  labelText: 'Total Time (hours)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (!widget.useTimer) {
                    if (value == null || value.isEmpty) {
                      return 'Enter time spent';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  if (!widget.useTimer) {
                    totalTime = double.parse(value!);
                  }
                },
              ),
            ],
            const SizedBox(height: 12),
            // Project dropdown
            DropdownButtonFormField<String>(
              initialValue: projectId,
              items: projectProvider.projects.map((project) {
                return DropdownMenuItem(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  projectId = value;
                  taskId = null;
                  _newTaskController.clear();
                });
              },
              validator: (value) => value == null ? 'Select a project' : null,
              decoration: const InputDecoration(labelText: 'Project'),
            ),

            const SizedBox(height: 12),

            // Task dropdown (optional)
            if (projectId != null)
              DropdownButtonFormField<String>(
                initialValue: taskId,
                items: projectProvider
                    .getTasksForProject(projectId!)
                    .map(
                      (task) => DropdownMenuItem(
                        value: task.id,
                        child: Text(task.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    taskId = value;
                    _newTaskController.clear();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select an existing task (optional)',
                ),
              ),

            const SizedBox(height: 12),

            // New task input
            TextFormField(
              controller: _newTaskController,
              decoration: const InputDecoration(
                labelText: 'Or enter a new task',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    taskId = null; // clear selection if typing new task
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Time
            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Total Time',
                hintText: 'e.g. 1:30 for 1 hour 30 minutes',
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter time spent';
                final parts = value.split(':');
                if (parts.length != 2) return 'Use HH:mm format';
                final hours = int.tryParse(parts[0]);
                final minutes = int.tryParse(parts[1]);
                if (hours == null || minutes == null || minutes >= 60) {
                  return 'Enter a valud time (e.g. 2:15)';
                }
                return null;
              },

              onSaved: (value) {
                final parts = value!.split(':');
                final hours = int.parse(parts[0]);
                final minutes = int.parse(parts[1]);
                totalTime = hours + (minutes / 60.0); // store as decimal
              },
            ),

            const SizedBox(height: 12),

            // Notes
            TextFormField(
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notes = value ?? '',
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (projectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a project')),
                    );
                    return;
                  }

                  // Either use selected task or create new task
                  String finalTaskId;
                  if (_newTaskController.text.trim().isNotEmpty) {
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: projectId!,
                      name: _newTaskController.text.trim(),
                      status: 'not started',
                      notes: '',
                    );
                    projectProvider.addTask(newTask);
                    finalTaskId = newTask.id;
                  } else if (taskId != null) {
                    finalTaskId = taskId!;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select or enter a task'),
                      ),
                    );
                    return;
                  }

                  _formKey.currentState!.save();

                  // If timer mode -> derive hours from elapsed
                  if (widget.useTimer) {
                    totalTime = widget._elapsed.inMinutes / 60.0;
                  }

                  Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  ).addTimeEntry(
                    TimeEntry(
                      id: DateTime.now().toIso8601String(),
                      projectId: projectId!,
                      taskId: finalTaskId,
                      totalTime: totalTime,
                      date: DateTime.now(),
                      notes: notes,
                    ),
                    projectProvider,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
