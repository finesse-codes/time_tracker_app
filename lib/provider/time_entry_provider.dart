import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:time_tracker/models/time_model.dart';
import 'package:localstorage/localstorage.dart';

enum TimeEntrySort { date, project }

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;

  List<TimeEntry> _entries = [];
  TimeEntrySort _sortBy = TimeEntrySort.date;

  TimeEntryProvider({required this.storage}) {
    _loadEntriesFromStorage();
  }

  List<TimeEntry> get entries {
    final sorted = [..._entries]; // make a copy so we don't mutate
    if (_sortBy == TimeEntrySort.date) {
      sorted.sort((a, b) => b.date.compareTo(a.date)); // newest first
    } else if (_sortBy == TimeEntrySort.project) {
      sorted.sort((a, b) => a.projectId.compareTo(b.projectId));
    }
    return sorted;
  }

  TimeEntrySort get sortBy => _sortBy;
  void setSortBy(TimeEntrySort sort) {
    _sortBy = sort;
    notifyListeners();
  }

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
