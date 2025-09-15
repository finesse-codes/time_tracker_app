import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/utils/app_button.dart';
import 'package:time_tracker/utils/app_dropdown.dart';
import 'package:time_tracker/utils/app_text_field.dart';
import '../models/time_model.dart';
import '../models/task_model.dart';
import '../provider/time_entry_provider.dart';
import '../provider/project_task_provider.dart';
import 'dart:async';

class AddTimeEntryScreen extends StatefulWidget {
  final String? initialProjectId;
  final String? initialTaskId;

  const AddTimeEntryScreen({
    super.key,
    this.initialProjectId,
    this.initialTaskId,
  });

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Project/task fields
  String? projectId;
  String? taskId;
  final _newTaskController = TextEditingController();
  final _notesController = TextEditingController();

  // Time fields
  double totalTime = 0.0;
  String notes = '';
  final _timeController = TextEditingController();

  // Timer state
  bool _useTimer = false;
  bool _isRunning = false;
  bool _isPaused = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    projectId = widget.initialProjectId;
    taskId = widget.initialTaskId;
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ---------------- TIMER METHODS ----------------
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning && !_isPaused) {
      _timer?.cancel();
      setState(() => _isPaused = true);
    }
  }

  void _resumeTimer() {
    if (_isRunning && _isPaused) {
      _startTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    // Fill in total time in HH:mm for the time field
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    _timeController.text =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    // update totalTime in hours
    setState(() {
      totalTime = _elapsed.inMinutes / 60.0;
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // ---------------- BUILD ----------------
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
            // ---------------- TIMER BUTTON ----------------
            // ---------------- TIMER BUTTON ----------------
            Column(
              children: [
                // Show elapsed time text if timer has ever started
                if (_elapsed.inSeconds > 0 || _isRunning)
                  Text(
                    _formatDuration(_elapsed),
                    style: TextStyle(
                      fontSize: 60,
                      color: Colors.blue.shade300,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRunning && !_isPaused)
                      // Only pause button while running
                      IconButton(
                        iconSize: 50,
                        color: Colors.blue,
                        icon: const Icon(Icons.pause_circle_filled),
                        onPressed: _pauseTimer,
                      )
                    else if (_isPaused)
                      // Resume + Stop when paused
                      Row(
                        children: [
                          IconButton(
                            iconSize: 50,
                            color: Colors.blue,
                            icon: const Icon(Icons.play_circle_fill_outlined),
                            onPressed: _resumeTimer,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            iconSize: 50,
                            color: Colors.blue,
                            icon: const Icon(Icons.stop_circle_outlined),
                            onPressed: _stopTimer,
                          ),
                        ],
                      )
                    else
                      // Initial state → show start button
                      IconButton(
                        iconSize: 50,
                        color: Colors.blue,
                        icon: const Icon(Icons.play_circle_fill_outlined),
                        onPressed: _startTimer,
                      ),
                  ],
                ),
              ],
            ),

            // ---------------- TIMER DISPLAY ----------------
            if (_useTimer) ...[
              Text(
                _formatDuration(_elapsed),
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
              const SizedBox(height: 12),
            ] else ...[
              // ---------------- MANUAL TIME ENTRY ----------------
              AppTextField(
                controller: _timeController,
                label: 'Total Time',
                hintText: 'e.g. 1:30 for 1 hour 30 minutes',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (!_useTimer) {
                    if (value == null || value.isEmpty) {
                      return 'Enter time spent';
                    }
                    final parts = value.split(':');
                    if (parts.length != 2) return 'Use HH:mm format';
                    final hours = int.tryParse(parts[0]);
                    final minutes = int.tryParse(parts[1]);
                    if (hours == null || minutes == null || minutes >= 60) {
                      return 'Enter a valid time (e.g. 2:15)';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  if (!_useTimer) {
                    final parts = value!.split(':');
                    final hours = int.parse(parts[0]);
                    final minutes = int.parse(parts[1]);
                    totalTime = hours + minutes / 60.0;
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            // ---------------- PROJECT DROPDOWN ----------------
            AppDropdown(
              initialValue: projectId,
              items: projectProvider.projects
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  projectId = val;
                  taskId = null;
                  _newTaskController.clear();
                });
              },
              validator: (val) => val == null ? 'Select a project' : null,
              label: 'Project',
            ),

            const SizedBox(height: 12),

            // ---------------- TASK DROPDOWN ----------------
            if (projectId != null)
              AppDropdown(
                initialValue: taskId,
                items: projectProvider
                    .getTasksForProject(projectId!)
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    taskId = val;
                    _newTaskController.clear();
                  });
                },
                label: 'Select an existing task (optional)',
              ),

            const SizedBox(height: 12),

            // ---------------- NEW TASK INPUT ----------------
            AppTextField(
              controller: _newTaskController,
              label: 'optional - create a new task',
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() => taskId = null);
                }
              },
              hintText: 'new task',
            ),

            const SizedBox(height: 12),

            // ---------------- NOTES ----------------
            AppTextField(
              label: 'Notes',
              controller: _notesController,
              onSaved: (val) => notes = val ?? '',
            ),

            const SizedBox(height: 16),

            // ---------------- SAVE BUTTON ----------------
            AppButton(
              text: "save",
              variant: ButtonVariant.solid,
              type: ButtonType.primary,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                if (projectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a project')),
                  );
                  return;
                }

                _formKey.currentState!.save();

                // Determine final task
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

                // Timer mode → derive hours from elapsed
                if (_useTimer) totalTime = _elapsed.inMinutes / 60.0;

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
              },
            ),
          ],
        ),
      ),
    );
  }
}
