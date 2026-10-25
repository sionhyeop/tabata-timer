import 'package:flutter/painting.dart';

import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import 'value_tile.dart';

/// The adjustable values for a config's mode. Shared by the Timer tab and
/// the routine editor so both look and behave the same.
List<ConfigField> configFields(WorkoutConfig c, void Function(WorkoutConfig updated) onChanged) {
  ConfigField duration(
    String label,
    int value,
    WorkoutConfig Function(int v) apply, {
    int min = 0,
    int max = 3600,
    String? zeroLabel,
    Color dot = AppColors.work,
  }) => ConfigField(
    label: label,
    kind: ValueKind.duration,
    value: value,
    min: min,
    max: max,
    dot: dot,
    zeroLabel: zeroLabel,
    onChanged: (v) => onChanged(apply(v)),
  );

  ConfigField count(String label, int value, WorkoutConfig Function(int v) apply, {int max = 99}) =>
      ConfigField(
        label: label,
        kind: ValueKind.count,
        value: value,
        min: 1,
        max: max,
        onChanged: (v) => onChanged(apply(v)),
      );

  final work = duration('운동', c.workSec, (v) => c.copyWith(workSec: v), min: 5);
  final rest = duration(
    '휴식',
    c.restSec,
    (v) => c.copyWith(restSec: v),
    zeroLabel: '없음',
    dot: AppColors.rest,
  );
  final rounds = count('라운드', c.rounds, (v) => c.copyWith(rounds: v));
  final sets = count('세트', c.sets, (v) => c.copyWith(sets: v), max: 20);
  final setRest = duration(
    '세트 간 휴식',
    c.setRestSec,
    (v) => c.copyWith(setRestSec: v),
    zeroLabel: '없음',
    dot: AppColors.setRest,
  );

  return switch (c.mode) {
    TimerMode.tabata => [work, rest, rounds, sets, if (c.sets > 1) setRest],
    TimerMode.interval => [
      work,
      rest,
      rounds,
      sets,
      setRest,
      duration(
        '웜업',
        c.warmupSec,
        (v) => c.copyWith(warmupSec: v),
        zeroLabel: '없음',
        dot: AppColors.warmCool,
      ),
      duration(
        '쿨다운',
        c.cooldownSec,
        (v) => c.copyWith(cooldownSec: v),
        zeroLabel: '없음',
        dot: AppColors.warmCool,
      ),
    ],
    TimerMode.emom => [duration('간격', c.workSec, (v) => c.copyWith(workSec: v), min: 10), rounds],
    TimerMode.amrap => [
      duration('제한 시간', c.workSec, (v) => c.copyWith(workSec: v), min: 30, max: 7200),
    ],
    TimerMode.forTime => [
      duration('타임캡', c.workSec, (v) => c.copyWith(workSec: v), max: 7200, zeroLabel: '없음'),
    ],
    TimerMode.rest => [
      duration(
        '휴식 시간',
        c.workSec,
        (v) => c.copyWith(workSec: v),
        min: 5,
        max: 1800,
        dot: AppColors.rest,
      ),
    ],
  };
}
