import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/workout_config.dart';
import 'default_routines.dart';

class RoutineStore extends ChangeNotifier {
  RoutineStore(this._prefs, AppLocalizations strings) {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _routines.addAll(defaultRoutines(strings));
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

  void duplicate(WorkoutConfig routine, {required String name}) {
    final i = _routines.indexWhere((r) => r.id == routine.id);
    _routines.insert(i + 1, routine.copyWith(id: newId(), name: name));
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

  /// Default routines the user hasn't renamed or re-listed follow the app
  /// language; edited ones keep the user's words.
  void localizePresets(AppLocalizations strings) {
    final current = {for (final p in defaultRoutines(strings)) p.id: p};
    final everyLanguage = [
      for (final locale in AppLocalizations.supportedLocales)
        ...defaultRoutines(lookupAppLocalizations(locale)),
    ];
    var changed = false;
    for (var i = 0; i < _routines.length; i++) {
      final r = _routines[i];
      final preset = current[r.id];
      if (preset == null) continue;
      final variants = everyLanguage.where((p) => p.id == r.id);
      final name = variants.any((p) => p.name == r.name) ? preset.name : r.name;
      final exercises = variants.any((p) => listEquals(p.exercises, r.exercises))
          ? preset.exercises
          : r.exercises;
      if (name == r.name && listEquals(exercises, r.exercises)) continue;
      _routines[i] = r.copyWith(name: name, exercises: exercises);
      changed = true;
    }
    if (!changed) return;
    _persist();
    notifyListeners();
  }

  void _persist() => _prefs.setString(_key, jsonEncode(_routines.map((r) => r.toJson()).toList()));
}
