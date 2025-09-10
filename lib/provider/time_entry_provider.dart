import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:time_tracker/models/time_model.dart';
import 'package:localstorage/localstorage.dart';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  List<TimeEntry> _entries = [];

  TimeEntryProvider({required this.storage}) {
    _loadEntriesFromStorage();
  }

  List<TimeEntry> get entries => _entries;

  void _loadEntriesFromStorage() async {
    try {
      var data = storage.getItem('entries');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);

        _entries = decoded
            .map((item) {
              try {
                return TimeEntry.fromMap(item as Map<String, dynamic>);
              } catch (e) {
                debugPrint('⚠️ Skipping invalid entry: $e');
                return null; // skip bad items
              }
            })
            .whereType<TimeEntry>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load entries: $e');
      _entries = []; // fall back to empty list
    }
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveToStorage();
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void _saveToStorage() {
    try {
      final encoded = jsonEncode(
        _entries.map((entry) => entry.toMap()).toList(),
      );
      storage.setItem('entries', encoded);
    } catch (e) {
      debugPrint('⚠️ Failed to save entries: $e');
    }
  }
}
