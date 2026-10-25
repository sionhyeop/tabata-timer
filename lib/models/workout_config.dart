import 'timer_mode.dart';

/// Everything needed to build a workout timeline.
///
/// [workSec] is interpreted per mode: work interval (tabata, interval),
/// minute length (emom), time limit (amrap), time cap — 0 for none —
/// (forTime) or rest length (rest).
class WorkoutConfig {
  const WorkoutConfig({
    required this.id,
    required this.name,
    required this.mode,
    required this.workSec,
    this.restSec = 0,
    this.rounds = 1,
    this.sets = 1,
    this.setRestSec = 0,
    this.warmupSec = 0,
    this.cooldownSec = 0,
    this.exercises = const [],
  });

  final String id;
  final String name;
  final TimerMode mode;
  final int workSec;
  final int restSec;
  final int rounds;
  final int sets;
  final int setRestSec;
  final int warmupSec;
  final int cooldownSec;
  final List<String> exercises;

  static WorkoutConfig defaults(TimerMode mode) => switch (mode) {
    TimerMode.tabata => const WorkoutConfig(
      id: 'quick-tabata',
      name: '타바타',
      mode: TimerMode.tabata,
      workSec: 20,
      restSec: 10,
      rounds: 8,
      setRestSec: 60,
    ),
    TimerMode.interval => const WorkoutConfig(
      id: 'quick-interval',
      name: '인터벌',
      mode: TimerMode.interval,
      workSec: 40,
      restSec: 20,
      rounds: 6,
      sets: 3,
      setRestSec: 60,
    ),
    TimerMode.emom => const WorkoutConfig(
      id: 'quick-emom',
      name: 'EMOM',
      mode: TimerMode.emom,
      workSec: 60,
      rounds: 10,
    ),
    TimerMode.amrap => const WorkoutConfig(
      id: 'quick-amrap',
      name: 'AMRAP',
      mode: TimerMode.amrap,
      workSec: 12 * 60,
    ),
    TimerMode.forTime => const WorkoutConfig(
      id: 'quick-fortime',
      name: 'For Time',
      mode: TimerMode.forTime,
      workSec: 20 * 60,
    ),
    TimerMode.rest => const WorkoutConfig(
      id: 'quick-rest',
      name: '휴식',
      mode: TimerMode.rest,
      workSec: 90,
    ),
  };

  /// Short human summary, e.g. "20초 · 10초 · 8라운드".
  String get summary {
    String t(int s) => _shortDuration(s);
    return switch (mode) {
      TimerMode.tabata || TimerMode.interval => [
        '운동 ${t(workSec)}',
        if (restSec > 0) '휴식 ${t(restSec)}',
        '$rounds라운드',
        if (sets > 1) '$sets세트',
      ].join(' · '),
      TimerMode.emom => '${t(workSec)}마다 · $rounds라운드',
      TimerMode.amrap => '${t(workSec)} 동안 최대 라운드',
      TimerMode.forTime => workSec > 0 ? '타임캡 ${t(workSec)}' : '타임캡 없음',
      TimerMode.rest => '휴식 ${t(workSec)}',
    };
  }

  WorkoutConfig copyWith({
    String? id,
    String? name,
    TimerMode? mode,
    int? workSec,
    int? restSec,
    int? rounds,
    int? sets,
    int? setRestSec,
    int? warmupSec,
    int? cooldownSec,
    List<String>? exercises,
  }) => WorkoutConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    mode: mode ?? this.mode,
    workSec: workSec ?? this.workSec,
    restSec: restSec ?? this.restSec,
    rounds: rounds ?? this.rounds,
    sets: sets ?? this.sets,
    setRestSec: setRestSec ?? this.setRestSec,
    warmupSec: warmupSec ?? this.warmupSec,
    cooldownSec: cooldownSec ?? this.cooldownSec,
    exercises: exercises ?? this.exercises,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mode': mode.name,
    'workSec': workSec,
    'restSec': restSec,
    'rounds': rounds,
    'sets': sets,
    'setRestSec': setRestSec,
    'warmupSec': warmupSec,
    'cooldownSec': cooldownSec,
    'exercises': exercises,
  };

  factory WorkoutConfig.fromJson(Map<String, dynamic> json) => WorkoutConfig(
    id: json['id'] as String,
    name: json['name'] as String,
    mode: TimerMode.fromName(json['mode'] as String?),
    workSec: json['workSec'] as int,
    restSec: json['restSec'] as int? ?? 0,
    rounds: json['rounds'] as int? ?? 1,
    sets: json['sets'] as int? ?? 1,
    setRestSec: json['setRestSec'] as int? ?? 0,
    warmupSec: json['warmupSec'] as int? ?? 0,
    cooldownSec: json['cooldownSec'] as int? ?? 0,
    exercises: (json['exercises'] as List?)?.cast<String>() ?? const [],
  );
}

String _shortDuration(int sec) {
  if (sec < 60) return '$sec초';
  final m = sec ~/ 60;
  final s = sec % 60;
  return s == 0 ? '$m분' : '$m분 $s초';
}
