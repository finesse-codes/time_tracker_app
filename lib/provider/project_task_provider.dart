import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

class ProjectTaskProvider with ChangeNotifier {
  final StorageService<Project> projectStorage;
  final StorageService<Task> taskStorage;

  List<Project> _projects = [];
  List<Task> _tasks = [];

  ProjectTaskProvider({required LocalStorage storage})
    : projectStorage = StorageService<Project>(
        storage: storage,
        key: 'projects',
        fromMap: (map) => Project.fromMap(map),
      ),
      taskStorage = StorageService<Task>(
        storage: storage,
        key: 'tasks',
        fromMap: (map) => Task.fromMap(map),
      ) {
    _projects = projectStorage.load();
    _tasks = taskStorage.load();
  }

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  void addProject(Project project) {
    _projects.add(project);
    projectStorage.save(_projects);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    taskStorage.save(_tasks);
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    projectStorage.save(_projects);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    taskStorage.save(_tasks);
    notifyListeners();
  }

  // Return the Project object or null if not found
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Task> getTasksForProject(String projectId) {
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  // Shortcut to get a project's name with a fallback
  String getProjectName(String projectId) {
    return getProjectById(projectId)?.name ?? 'Unknown Project';
  }

  // Return the Task object or null if not found
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  Task? getTaskByIdandPID(String taskId, String projectId) {
    try {
      return tasks.firstWhere(
        (t) => t.id == taskId && t.projectId == projectId,
      );
    } catch (_) {
      return null;
    }
  }

  // Shortcut to get task name with a fallback
  String getTaskName(String taskId) {
    return getTaskById(taskId)?.name ?? 'Unknown Task';
  }

  // Get number of tasks completed vs total
  Map<String, int> getTaskCompletion(String projectId) {
    final projectTasks = tasks.where((t) => t.projectId == projectId).toList();
    final completed = projectTasks.where((t) => t.status == "completed").length;
    return {"completed": completed, "total": projectTasks.length};
  }
}
