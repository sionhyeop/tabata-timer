import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_config.dart';
import 'default_routines.dart';

class RoutineStore extends ChangeNotifier {
  RoutineStore(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _routines.addAll(defaultRoutines);
      _persist();
    } else {
      _routines.addAll(
        (jsonDecode(raw) as List).map((e) => WorkoutConfig.fromJson(e as Map<String, dynamic>)),
      );
    }
    _lastUsedId = _prefs.getString(_lastUsedKey);
  }

  static const _key = 'routines';
  static const _lastUsedKey = 'routines_last_used';

  final SharedPreferences _prefs;
  final List<WorkoutConfig> _routines = [];
  String? _lastUsedId;

  List<WorkoutConfig> get routines => List.unmodifiable(_routines);

  WorkoutConfig? byId(String? id) {
    for (final r in _routines) {
      if (r.id == id) return r;
    }
    return null;
  }

  WorkoutConfig? get lastUsed => byId(_lastUsedId);

  static String newId() => 'r${DateTime.now().microsecondsSinceEpoch}';

  /// Inserts a new routine at the top, or replaces one with the same id.
  void save(WorkoutConfig routine) {
    final i = _routines.indexWhere((r) => r.id == routine.id);
    if (i >= 0) {
      _routines[i] = routine;
    } else {
      _routines.insert(0, routine);
    }
    _persist();
    notifyListeners();
  }

  void duplicate(WorkoutConfig routine) {
    final i = _routines.indexWhere((r) => r.id == routine.id);
    _routines.insert(i + 1, routine.copyWith(id: newId(), name: '${routine.name} 복사본'));
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _routines.removeWhere((r) => r.id == id);
    _persist();
    notifyListeners();
  }

  void markUsed(String id) {
    _lastUsedId = id;
    _prefs.setString(_lastUsedKey, id);
    notifyListeners();
  }

  void _persist() => _prefs.setString(_key, jsonEncode(_routines.map((r) => r.toJson()).toList()));
}
