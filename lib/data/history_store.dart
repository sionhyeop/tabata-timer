import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_record.dart';
import '../utils/format.dart';

class WeekStats {
  const WeekStats({
    required this.days,
    required this.secondsPerDay,
    required this.totalSec,
    required this.count,
  });

  /// Monday … Sunday of the current week.
  final List<DateTime> days;
  final List<int> secondsPerDay;
  final int totalSec;
  final int count;
}

class HistoryStore extends ChangeNotifier {
  HistoryStore(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      _records.addAll(
        (jsonDecode(raw) as List).map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>)),
      );
      _sort();
    }
  }

  static const _key = 'history';

  final SharedPreferences _prefs;
  final List<WorkoutRecord> _records = [];

  /// Newest first.
  List<WorkoutRecord> get records => List.unmodifiable(_records);

  void add(WorkoutRecord record) {
    _records.add(record);
    _sort();
    _persist();
    notifyListeners();
  }

  void update(WorkoutRecord record) {
    final i = _records.indexWhere((r) => r.id == record.id);
    if (i < 0) return;
    _records[i] = record;
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _records.removeWhere((r) => r.id == id);
    _persist();
    notifyListeners();
  }

  void clear() {
    _records.clear();
    _persist();
    notifyListeners();
  }

  WeekStats weekStats(DateTime now) => computeWeekStats(_records, now);
  int streak(DateTime now) => computeStreak(_records, now);

  void _sort() => _records.sort((a, b) => b.startedAt.compareTo(a.startedAt));

  void _persist() => _prefs.setString(_key, jsonEncode(_records.map((r) => r.toJson()).toList()));
}

WeekStats computeWeekStats(List<WorkoutRecord> records, DateTime now) {
  final monday = dateOnly(now).subtract(Duration(days: now.weekday - 1));
  final days = [for (var i = 0; i < 7; i++) DateTime(monday.year, monday.month, monday.day + i)];
  final perDay = List<int>.filled(7, 0);
  var count = 0;
  for (final r in records) {
    final day = dateOnly(r.startedAt);
    final i = days.indexOf(day);
    if (i < 0) continue;
    perDay[i] += r.activeMs ~/ 1000;
    count++;
  }
  return WeekStats(
    days: days,
    secondsPerDay: perDay,
    totalSec: perDay.fold(0, (a, b) => a + b),
    count: count,
  );
}

/// Consecutive days with a workout, counting back from today — or from
/// yesterday, so the streak isn't shown as broken before today's session.
int computeStreak(List<WorkoutRecord> records, DateTime now) {
  final days = {for (final r in records) dateOnly(r.startedAt)};
  var day = dateOnly(now);
  if (!days.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}
