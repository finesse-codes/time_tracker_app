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
}
