import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/timer_mode.dart';
import '../models/workout_config.dart';

/// What the Timer tab shows: the selected mode and the last values the user
/// dialed in for each mode, so switching modes never loses settings.
class TimerSetupStore extends ChangeNotifier {
  TimerSetupStore(this._prefs) {
    _mode = TimerMode.fromName(_prefs.getString(_modeKey));
    final raw = _prefs.getString(_configsKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final config = WorkoutConfig.fromJson(entry.value as Map<String, dynamic>);
        _configs[config.mode] = config;
      }
    }
  }

  static const _modeKey = 'setup_mode';
  static const _configsKey = 'setup_configs';

  final SharedPreferences _prefs;
  late TimerMode _mode;
  final Map<TimerMode, WorkoutConfig> _configs = {};

  TimerMode get mode => _mode;
  WorkoutConfig get config => configFor(_mode);
  WorkoutConfig configFor(TimerMode mode) => _configs[mode] ?? WorkoutConfig.defaults(mode);

  void selectMode(TimerMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _prefs.setString(_modeKey, mode.name);
    notifyListeners();
  }

  void update(WorkoutConfig config) {
    _configs[config.mode] = config;
    _prefs.setString(
      _configsKey,
      jsonEncode({for (final c in _configs.values) c.mode.name: c.toJson()}),
    );
    notifyListeners();
  }

  void reset() => update(WorkoutConfig.defaults(_mode));
}
