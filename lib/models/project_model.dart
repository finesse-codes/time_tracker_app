import 'package:intl/intl.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String startDate;

  Project({required this.id, required this.name, required this.description})
    : startDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }
}
