import 'timer_mode.dart';

/// A finished (or stopped) workout, stored in history.
class WorkoutRecord {
  const WorkoutRecord({
    required this.id,
    required this.name,
    required this.mode,
    required this.startedAt,
    required this.activeMs,
    required this.completed,
    this.workRounds = 0,
    this.amrapRounds = 0,
    this.laps = const [],
    this.rpe,
    this.kcal = 0,
  });

  final String id;
  final String name;
  final TimerMode mode;
  final DateTime startedAt;

  /// Time actually spent running (pauses excluded).
  final int activeMs;
  final bool completed;

  /// Work intervals finished (tabata / interval / emom).
  final int workRounds;

  /// Rounds counted by the user (amrap).
  final int amrapRounds;

  /// Split times in ms since the main step began (forTime).
  final List<int> laps;

  /// Perceived effort, 1 (easy) – 5 (max). Null if not rated.
  final int? rpe;
  final int kcal;

  WorkoutRecord copyWith({int? rpe}) => WorkoutRecord(
    id: id,
    name: name,
    mode: mode,
    startedAt: startedAt,
    activeMs: activeMs,
    completed: completed,
    workRounds: workRounds,
    amrapRounds: amrapRounds,
    laps: laps,
    rpe: rpe ?? this.rpe,
    kcal: kcal,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mode': mode.name,
    'startedAt': startedAt.toIso8601String(),
    'activeMs': activeMs,
    'completed': completed,
    'workRounds': workRounds,
    'amrapRounds': amrapRounds,
    'laps': laps,
    'rpe': rpe,
    'kcal': kcal,
  };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
    id: json['id'] as String,
    name: json['name'] as String,
    mode: TimerMode.fromName(json['mode'] as String?),
    startedAt: DateTime.parse(json['startedAt'] as String),
    activeMs: json['activeMs'] as int,
    completed: json['completed'] as bool? ?? true,
    workRounds: json['workRounds'] as int? ?? 0,
    amrapRounds: json['amrapRounds'] as int? ?? 0,
    laps: (json['laps'] as List?)?.cast<int>() ?? const [],
    rpe: json['rpe'] as int?,
    kcal: json['kcal'] as int? ?? 0,
  );
}
