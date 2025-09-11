import 'dart:convert';
import 'package:localstorage/localstorage.dart';

// this service knows how to load/save any model that has a fromMap / toMap
class StorageService<T> {
  final LocalStorage storage;
  final String key;
  final T Function(Map<String, dynamic>) fromMap;

  StorageService({
    required this.storage,
    required this.key,
    required this.fromMap,
  });

  /// Load items from local storage
  List<T> load() {
    var data = storage.getItem(key);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded
        .map((item) => fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Save items to local storage
  void save(List<T> items) {
    final encoded = jsonEncode(
      items.map((e) => (e as dynamic).toMap()).toList(),
    );
    storage.setItem(key, encoded);
  }
}
