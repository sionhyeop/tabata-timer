import 'package:flutter/painting.dart';

import '../../l10n/app_localizations.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import 'value_tile.dart';

/// The adjustable values for a config's mode. Shared by the Timer tab and
/// the routine editor so both look and behave the same.
List<ConfigField> configFields(
  AppLocalizations s,
  WorkoutConfig c,
  void Function(WorkoutConfig updated) onChanged,
) {
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

  final work = duration(s.phaseWork, c.workSec, (v) => c.copyWith(workSec: v), min: 5);
  final rest = duration(
    s.phaseRest,
    c.restSec,
    (v) => c.copyWith(restSec: v),
    zeroLabel: s.none,
    dot: AppColors.rest,
  );
  final rounds = count(s.fieldRounds, c.rounds, (v) => c.copyWith(rounds: v));
  final sets = count(s.fieldSets, c.sets, (v) => c.copyWith(sets: v), max: 20);
  final setRest = duration(
    s.fieldSetRest,
    c.setRestSec,
    (v) => c.copyWith(setRestSec: v),
    zeroLabel: s.none,
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
        s.phaseWarmup,
        c.warmupSec,
        (v) => c.copyWith(warmupSec: v),
        zeroLabel: s.none,
        dot: AppColors.warmCool,
      ),
      duration(
        s.phaseCooldown,
        c.cooldownSec,
        (v) => c.copyWith(cooldownSec: v),
        zeroLabel: s.none,
        dot: AppColors.warmCool,
      ),
    ],
    TimerMode.emom => [
      duration(s.fieldInterval, c.workSec, (v) => c.copyWith(workSec: v), min: 10),
      rounds,
    ],
    TimerMode.amrap => [
      duration(s.timeLimit, c.workSec, (v) => c.copyWith(workSec: v), min: 30, max: 7200),
    ],
    TimerMode.forTime => [
      duration(s.timeCap, c.workSec, (v) => c.copyWith(workSec: v), max: 7200, zeroLabel: s.none),
    ],
    TimerMode.rest => [
      duration(
        s.fieldRestTime,
        c.workSec,
        (v) => c.copyWith(workSec: v),
        min: 5,
        max: 1800,
        dot: AppColors.rest,
      ),
    ],
  };
}
